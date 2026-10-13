param(
  [string]$InputFile = 'rider_feature_inventory_2026-10-13.json',
  [string]$OutputFile = 'AgriSell_Rider_Features_and_Missing_Items_2026-10-13.docx'
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$report = Get-Content -LiteralPath (Join-Path $PSScriptRoot $InputFile) -Raw -Encoding UTF8 | ConvertFrom-Json
$outputPath = Join-Path $PSScriptRoot $OutputFile
function Escape-Xml([string]$value) { [System.Security.SecurityElement]::Escape($value) }
function Paragraph([string]$value, [string]$style = 'Normal') {
  $runs = @($value -split '\r?\n' | ForEach-Object {
    "<w:r><w:t xml:space='preserve'>$(Escape-Xml $_)</w:t></w:r>"
  }) -join '<w:r><w:br/></w:r>'
  return "<w:p><w:pPr><w:pStyle w:val='$style'/></w:pPr>$runs</w:p>"
}
function Table($rows) {
  $xml = "<w:tbl><w:tblPr><w:tblW w:w='9746' w:type='dxa'/><w:tblLayout w:type='fixed'/><w:tblBorders><w:top w:val='single' w:sz='4' w:color='CFDAD3'/><w:left w:val='single' w:sz='4' w:color='CFDAD3'/><w:bottom w:val='single' w:sz='4' w:color='CFDAD3'/><w:right w:val='single' w:sz='4' w:color='CFDAD3'/><w:insideH w:val='single' w:sz='4' w:color='CFDAD3'/><w:insideV w:val='single' w:sz='4' w:color='CFDAD3'/></w:tblBorders><w:tblCellMar><w:top w:w='80' w:type='dxa'/><w:left w:w='120' w:type='dxa'/><w:bottom w:w='80' w:type='dxa'/><w:right w:w='120' w:type='dxa'/></w:tblCellMar></w:tblPr><w:tblGrid><w:gridCol w:w='2300'/><w:gridCol w:w='7446'/></w:tblGrid>"
  $index = 0
  foreach ($row in $rows) {
    $header = if ($index -eq 0) { '<w:tblHeader/>' } else { '' }
    $xml += "<w:tr><w:trPr><w:cantSplit/>$header</w:trPr>"
    for ($column = 0; $column -lt 2; $column++) {
      $width = if ($column -eq 0) { 2300 } else { 7446 }
      $color = if ($index -eq 0) { '1D633B' } elseif ($index % 2 -eq 1) { 'F1F6F2' } else { 'FFFFFF' }
      $style = if ($index -eq 0) { 'TableHeader' } elseif ($column -eq 0) { 'TableLabel' } else { 'TableText' }
      $xml += "<w:tc><w:tcPr><w:tcW w:w='$width' w:type='dxa'/><w:shd w:fill='$color'/><w:vAlign w:val='top'/></w:tcPr>$(Paragraph $row[$column] $style)</w:tc>"
    }
    $xml += '</w:tr>'
    $index++
  }
  if ($report.title -match 'Questionnaire') {
    $xml = $xml.Replace("w:w='2300'", "w:w='4600'").Replace("w:w='7446'", "w:w='5146'")
  }
  return $xml + '</w:tbl>'
}
$body = ''
$index = 0
foreach ($page in $report.pages) {
  if ($index -gt 0) { $body += '<w:p><w:r><w:br w:type="page"/></w:r></w:p>' }
  $body += Paragraph $report.title 'Eyebrow'
  if ($index -eq 0) {
    $body += Paragraph $report.title 'Title'
    $body += Paragraph $report.subtitle 'Subtitle'
    $body += Paragraph $report.date 'Date'
  }
  $body += Paragraph $page.heading 'Heading1'
  $body += Paragraph $page.lead 'Lead'
  if ($page.rows) { $body += Table $page.rows }
  foreach ($paragraph in $page.paragraphs) { $body += Paragraph $paragraph }
  $index++
}
$section = '<w:sectPr><w:footerReference w:type="default" r:id="rId2"/><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="900" w:right="1080" w:bottom="1000" w:left="1080" w:header="360" w:footer="440"/></w:sectPr>'
$document = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:body>' + $body + $section + '</w:body></w:document>'
$styles = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/><w:sz w:val="21"/><w:color w:val="26342B"/><w:lang w:val="en-PH"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="130" w:line="250" w:lineRule="auto"/><w:widowControl/></w:pPr></w:pPrDefault></w:docDefaults>
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/></w:style>
<w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:basedOn w:val="Normal"/><w:pPr><w:keepNext/><w:spacing w:before="120" w:after="100"/></w:pPr><w:rPr><w:b/><w:color w:val="1D633B"/><w:sz w:val="44"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Subtitle"><w:name w:val="Subtitle"/><w:basedOn w:val="Normal"/><w:pPr><w:keepNext/></w:pPr><w:rPr><w:sz w:val="26"/><w:color w:val="52675A"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Date"><w:name w:val="Date"/><w:basedOn w:val="Normal"/><w:pPr><w:keepNext/><w:spacing w:after="190"/></w:pPr><w:rPr><w:sz w:val="19"/><w:color w:val="52675A"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Eyebrow"><w:name w:val="Eyebrow"/><w:basedOn w:val="Normal"/><w:pPr><w:keepNext/><w:spacing w:after="130"/></w:pPr><w:rPr><w:b/><w:sz w:val="17"/><w:color w:val="52675A"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="Heading 1"/><w:basedOn w:val="Normal"/><w:pPr><w:keepNext/><w:outlineLvl w:val="0"/><w:spacing w:before="120" w:after="150"/></w:pPr><w:rPr><w:b/><w:sz w:val="29"/><w:color w:val="1D633B"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Lead"><w:name w:val="Lead"/><w:basedOn w:val="Normal"/><w:pPr><w:keepNext/><w:spacing w:after="170"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="TableText"><w:name w:val="Table Text"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:after="20" w:line="225" w:lineRule="auto"/></w:pPr><w:rPr><w:sz w:val="19"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="TableLabel"><w:name w:val="Table Label"/><w:basedOn w:val="TableText"/><w:rPr><w:b/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="TableHeader"><w:name w:val="Table Header"/><w:basedOn w:val="TableText"/><w:rPr><w:b/><w:color w:val="FFFFFF"/></w:rPr></w:style>
</w:styles>
'@
$types = '<?xml version="1.0" encoding="UTF-8"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/><Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/><Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/><Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/></Types>'
$rels = '<?xml version="1.0" encoding="UTF-8"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/><Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/></Relationships>'
$wordRels = '<?xml version="1.0" encoding="UTF-8"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/><Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml"/></Relationships>'
$footer = '<?xml version="1.0" encoding="UTF-8"?><w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:p><w:pPr><w:jc w:val="right"/></w:pPr><w:r><w:rPr><w:sz w:val="17"/><w:color w:val="52675A"/></w:rPr><w:t>AgriSell Rider Review | October 13, 2026 | Page </w:t></w:r><w:fldSimple w:instr="PAGE"/></w:p></w:ftr>'
$core = '<?xml version="1.0" encoding="UTF-8"?><cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/"><dc:title>AgriSell Rider Features and Missing Items</dc:title><dc:subject>Current workspace review, October 13, 2026</dc:subject><dc:creator>AgriSell Project</dc:creator><dc:description>Implemented rider capabilities, confirmed gaps, pending database deployment and verification limits.</dc:description></cp:coreProperties>'
$parts = @{'[Content_Types].xml'=$types; '_rels/.rels'=$rels; 'word/document.xml'=$document; 'word/styles.xml'=$styles; 'word/_rels/document.xml.rels'=$wordRels; 'word/footer1.xml'=$footer; 'docProps/core.xml'=$core}
$parts['docProps/core.xml'] = $core.Replace('AgriSell Rider Features and Missing Items', (Escape-Xml $report.title)).Replace('Current workspace review, October 13, 2026', (Escape-Xml $report.subtitle))
$parts['docProps/core.xml'] = $parts['docProps/core.xml'].Replace('Implemented rider capabilities, confirmed gaps, pending database deployment and verification limits.', (Escape-Xml $report.subtitle))
$stream = [IO.File]::Open($outputPath, [IO.FileMode]::Create, [IO.FileAccess]::ReadWrite)
$archive = [IO.Compression.ZipArchive]::new($stream, [IO.Compression.ZipArchiveMode]::Create, $false)
try {
  foreach ($name in $parts.Keys) {
    [xml]$validXml = $parts[$name]
    $entry = $archive.CreateEntry($name)
    $writer = [IO.StreamWriter]::new($entry.Open(), [Text.UTF8Encoding]::new($false))
    try { $writer.Write($parts[$name]) } finally { $writer.Dispose() }
  }
} finally { $archive.Dispose(); $stream.Dispose() }
$archive = [IO.Compression.ZipFile]::OpenRead($outputPath)
try {
  foreach ($entry in $archive.Entries) {
    $reader = [IO.StreamReader]::new($entry.Open())
    try { [xml]$validated = $reader.ReadToEnd() } finally { $reader.Dispose() }
  }
  $parsed = [xml]$document
  $ns = [Xml.XmlNamespaceManager]::new($parsed.NameTable)
  $ns.AddNamespace('w', 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')
  $headings = $parsed.SelectNodes('//w:p[w:pPr/w:pStyle[@w:val="Heading1"]]', $ns).Count
  $breaks = $parsed.SelectNodes('//w:br[@w:type="page"]', $ns).Count
  $tables = $parsed.SelectNodes('//w:tbl', $ns).Count
  $expectedTables = @($report.pages | Where-Object { $_.rows }).Count
  if ($headings -ne $report.pages.Count -or $breaks -ne ($report.pages.Count - 1) -or $tables -ne $expectedTables) { throw 'Report structure validation failed' }
  Write-Output "Created and XML-validated: $outputPath"
  Write-Output "Sections: $headings; explicit page breaks: $breaks; tables: $tables; package parts: $($archive.Entries.Count)"
  Write-Output "Bytes: $((Get-Item -LiteralPath $outputPath).Length). Word/LibreOffice visual pagination is not verified."
} finally { $archive.Dispose() }
