# `<div>` Extraction
This directory contains 2 programs for reading in the big DPB XML file and writing out a bunch of little XML files, each with one `<div>` from the input. There is no particular reason to use one program over the other. The difference is entirely pedagogical. I have used this little project as an excuse to show how easy such a task can be _if you know the data_, and how much harder it is when you don’t.

1. `extract_divs_from_DPB.xslt` is specific to the DPB XML, or other TEI documents similar to it. It makes certain assumptions, as follows.
   * The input is in TEI
   * The outermost element is `<TEI>` (as opposed to `<teiCorpus>`)
   * There are no `<group>`s; nor any `<lem>`s, or `<rdg>`s, at least not any with a `<div>` in them
   * There are no PIs _after_ the outermost element
   * There are no comments outside the outermost element (at least none we want to keep)
   * Each output file should be called `DPB_div_[NNN].xml`, where [NNN] is a 3-digit number
   * Thus that there are hundreds (not thousands, nor merely tens) of `<div>`s

2. `extract_divs_from_XML.xslt` is general-purpose.
   * It does not assume the input is in any particular language; it does not even assume that the input is in only 1 language
   * It presumes that PIs and comments both before and after the outermost element of the input should be copied to be before or after the outermost element of each output file
   * Each output file is called `[inName]_div_[X].[inExt]`, where [inName] is the base filename of the input file without extension, [X] is a number which length is calculated to have sufficient digits to represent the number of `<div>`s, and [inExt] is the extension of the input file
   * A “colophon” is added as a final comment containing some useful metadata

In both cases the program’s output files are written to the `/tmp/` directory. No checking is done: if you do not have a read-write `/tmp/` directory the program will just crash.

Program #1 is pretty simple. It has 23 XSLT elements &amp; attributes, and took me 3–4 minutes to write (without comments, which took easily 3 times that long). The part that took the longest (by far) was getting the call to `format-number()` right. (I always have to look that one up.)

Program #2 is another story. Although it is not much more than twice as large with 57 XSLT elements &amp; attributes, it probably took ten times as long to write. The trickiest parts were the XPath for selecting the `<div>`s of interest and the calculation of the number of digits needed to represent the number of `<div>`s being extracted. (Part of the problem with the latter is I did not realize that the XPath function `math:log()` returns the natural logarithm, not the logarithm base 10.)

Program #1 defines the `<div>`s of interest to be those which are a child of the `<front>`, `<body>`, or `<back>`, itself a child of the `<text>`, itself a child of the outermost `<TEI>`. Expressed in XPath that is `/TEI/text/*/div`.

Program #2 has to work much harder to figure out which `<div>`s should be extracted. The basic idea is we want to extract the highest level `<div>`s, i.e. those that do not have an ancestor `<div>`. But we can’t just say `//div[ not( ancestor::div ) ]` because we do not know in what namespace (if any) each `<div>` is in. Furthermore, the only `<div>`s I do not want to extract are those that are a descendant of a `<div>` in the same namespace. (I go back and forth on whether that is actually the right behavior or not, but that is what I ended up making the program do.) Thus the XPath for selecting the `<div>`s to be extracted is quite gnarly: `//*[local-name(.) eq 'div'][not(ancestor::*[namespace-uri(.) eq namespace-uri(current()) and local-name(.) eq 'div'])]`. I find that a lot easier to read with some extra whitespace:
~~~
//*
   [ local-name(.) eq 'div']
   [ not(
          ancestor::*
                     [ 
                       namespace-uri( . ) eq namespace-uri( current() )
                       and
                       local-name( . ) eq 'div'
                     ]
        )
   ]
~~~
Either way, it’s a mouthful. (And it would not surprise me if someone could come up with a better, or at least clearer, way to say the same thing.)

—Syd Bauman, 2022-02-03

