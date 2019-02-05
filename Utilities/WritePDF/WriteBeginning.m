function WriteBeginning(aFid, aTitle, aPaperSize, aOrientation, aNumCols, aAuthorStr)
% Writes the beginning of a tex-document with plots to a file.
%
% The function writes latex code for a document with exported plots as
% figures. This function writes code for the beginning of the document. The
% document class and the page style are defined, lengths are defined,
% packages are loaded, the title is added, the author list is added, the
% date is added, the document is started, and the title page is created.
%
% Inputs:
% aFid - File identifier of an already open tex-file to write to.
% aTitle - Title of the document.
% aPaperSize - Paper size of the document (usually a4 or letter).
% aOrientation - Orientation of the paper (landscape or portrait).
% aNumCols - Number of text columns used in the document (1 or 2).
% aAuthorStr - String defining the author list. Latex syntax can be used.
%
% See also:
% SavePlotsGUI, SavePlots, SaveFigure, WriteClear, WriteEnd, WriteFigure,
% WriteTex

% Create a string specifying the number of columns used in the tex-file.
if aNumCols == 1
    colString = 'onecolumn';
elseif aNumCols == 2
    colString = 'twocolumn';
else
    error(['The tex-document must have either 1 or two columns. '...
        'You requested %d.'], aNumCols)
end

% Write the entire header of the file.
fprintf(aFid,[...
    '\\documentclass[' aPaperSize 'paper, titlepage, oneside, '...
    colString ', ' aOrientation ', 11pt]{article}\r\n'...
    '\r\n'...
    '\\pagestyle{empty}',...
    '\r\n'...
    '\\setlength{\\voffset}{-1in}\r\n'...
    '\\setlength{\\hoffset}{-1in}\r\n'...
    '\r\n'...
    '\\setlength{\\oddsidemargin}{0in}\r\n'...
    '\\setlength{\\evensidemargin}{0in}\r\n'...
    '\\setlength{\\headheight}{0in}\r\n'...
    '\\setlength{\\marginparsep}{0in}\r\n'...
    '\\setlength{\\footskip}{0in}\r\n'...
    '\\setlength{\\topmargin}{0in}\r\n'...
    '\\setlength{\\headsep}{0in}\r\n'...
    '\\setlength{\\textwidth}{\\paperwidth}\r\n'...
    '\\setlength{\\marginparwidth}{0in}\r\n'...
    '\\setlength{\\marginparpush}{0in}\r\n'...
    '\\setlength{\\textheight}{\\paperheight}\r\n'...
    '\r\n'...
    '\\newenvironment{changemargin}[2]{\r\n'...
    '\\begin{list}{}{\r\n'...
    '\\setlength{\\topsep}{0pt}\r\n'...
    '\\setlength{\\leftmargin}{#1}\r\n'...
    '\\setlength{\\rightmargin}{#2}\r\n'...
    '\\setlength{\\listparindent}{\\parindent}\r\n'...
    '\\setlength{\\itemindent}{\\parindent}\r\n'...
    '\\setlength{\\parsep}{\\parskip}\r\n'...
    '}\r\n'...
    '\\item[]}{\\end{list}}\r\n'...
    '\r\n'...
    '\\usepackage[english]{babel}\r\n'...
    '\\usepackage{graphicx}\r\n'...
    '\\usepackage[space]{grffile}\r\n'...
    '\r\n'...
    '\\title{' SpecChar(aTitle, 'sprintf') '}\r\n'...
    '\r\n'...
    '\\author{' SpecChar(aAuthorStr, 'sprintf') '}\r\n'...
    '\r\n'...
    '\\date{Created: \\today}\r\n'...
    '\r\n'...
    '\\begin{document}\r\n'...
    '\\maketitle\r\n']);
end