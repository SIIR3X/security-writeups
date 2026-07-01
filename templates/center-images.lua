-- Pandoc Lua filter: render the HTML-centered images as centered LaTeX figures.
--
-- The write-ups center images with raw HTML so they display centered on GitHub:
--     <p align="center">
--       <img src="images/foo.png" alt="..." width="80%">
--     </p>
-- Pandoc parses this as two RawBlocks (<p ...> and </p>) wrapping a Plain block
-- that holds the <img> as a RawInline. When producing a PDF via LaTeX, Pandoc
-- drops raw HTML, so the image disappears. This filter:
--   * removes the <p align="center"> and </p> wrappers, and
--   * turns the lone <img> into a centered \includegraphics, keeping the width.

local function img_src_width(inline)
  if inline.t == "RawInline" and inline.format == "html" then
    local src = inline.text:match('src="([^"]*)"')
    if src then
      return src, inline.text:match('width="([^"]*)"')
    end
  end
  return nil
end

-- Cap every screenshot to this fraction of the text height. Combined with
-- keepaspectratio, wide screenshots stay width-bound while tall ones (full web
-- pages) are shrunk to fit, so at least two images share a page instead of one
-- tall image leaving a large blank at the bottom.
-- The FIRST image (the challenge presentation) is shown large and prominent;
-- the rest are capped shorter so a tall screenshot does not leave a big blank.
local FIRST_MAX_HEIGHT = "0.82\\textheight"
local MAX_HEIGHT = "0.56\\textheight"
local image_index = 0

local function centered_figure(src, width)
  image_index = image_index + 1
  local maxh = (image_index == 1) and FIRST_MAX_HEIGHT or MAX_HEIGHT
  local w = "\\linewidth"
  if width then
    local pct = width:match("(%d+)%%")
    if pct then
      w = (tonumber(pct) / 100) .. "\\linewidth"
    else
      w = width
    end
  end
  local opts = "width=" .. w .. ",height=" .. maxh .. ",keepaspectratio"
  return pandoc.RawBlock(
    "latex",
    "\\begin{center}\\includegraphics[" .. opts .. "]{" .. src .. "}\\end{center}"
  )
end

local function convert(el)
  if #el.content == 1 then
    local src, width = img_src_width(el.content[1])
    if src then
      return centered_figure(src, width)
    end
  end
  return el
end

function Plain(el) return convert(el) end
function Para(el) return convert(el) end

-- Drop the <p align="center"> ... </p> wrappers themselves.
function RawBlock(el)
  if el.format == "html" and el.text:match("^%s*</?[pP][%s>]") then
    return {}
  end
  return el
end

-- Drop the top-level H1 title in the PDF: the metadata title block already
-- renders it. The H1 is kept in the Markdown for GitHub. Section headings are
-- H2/H3 and already carry their own manual numbers, so no auto-numbering.
function Header(el)
  if el.level == 1 then
    return {}
  end
  return el
end

-- Drop the metadata banner blockquote (Lab / Category / Difficulty / Legal
-- platform) that sits right under the H1. It exists for the GitHub rendering;
-- in the PDF the same information already appears on the cover page, so the
-- first blockquote is removed to avoid duplication.
local banner_dropped = false
function BlockQuote(el)
  if not banner_dropped then
    banner_dropped = true
    return {}
  end
  return el
end

-- Give every table proportional column widths based on the longest cell in each
-- column. Without this, pandoc emits unsized columns that do not wrap, so long
-- file names overflow onto the next column. With widths set, the LaTeX writer
-- uses wrapping p-columns.
function Table(tbl)
  local ncol = #tbl.colspecs
  if ncol == 0 then
    return tbl
  end

  local maxlen = {}
  for i = 1, ncol do maxlen[i] = 1 end

  local function scan(rows)
    for _, row in ipairs(rows) do
      for i, cell in ipairs(row.cells) do
        local len = #pandoc.utils.stringify(cell.contents)
        if len > maxlen[i] then maxlen[i] = len end
      end
    end
  end

  scan(tbl.head.rows)
  for _, body in ipairs(tbl.bodies) do
    scan(body.body)
  end

  local total = 0
  for i = 1, ncol do total = total + maxlen[i] end
  for i = 1, ncol do
    tbl.colspecs[i][2] = maxlen[i] / total
  end

  return tbl
end

-- Keep each screenshot with the short sentence that introduces it. After the
-- element filters above have turned the images into \includegraphics blocks,
-- this pass inserts a \needspace just before the sentence that precedes an
-- image: if the image (plus a couple of lines) would not fit in the remaining
-- space, the page breaks BEFORE that sentence, so the caption never dangles at
-- the bottom of a page with its image alone on the next one. The first image
-- (shown large) reserves more room than the others.
local function is_image_block(b)
  return b.t == "RawBlock" and b.format == "latex"
    and b.text:find("includegraphics", 1, true) ~= nil
end

function Pandoc(doc)
  local out = {}
  local seen = 0
  local blocks = doc.blocks
  for i = 1, #blocks do
    local b = blocks[i]
    local nxt = blocks[i + 1]
    if (b.t == "Para" or b.t == "Plain") and nxt and is_image_block(nxt) then
      local need = (seen == 0) and "0.9\\textheight" or "0.66\\textheight"
      table.insert(out, pandoc.RawBlock("latex", "\\needspace{" .. need .. "}"))
    end
    if is_image_block(b) then seen = seen + 1 end
    table.insert(out, b)
  end
  return pandoc.Pandoc(out, doc.meta)
end
