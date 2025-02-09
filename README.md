[![Actions Status](https://github.com/lizmat/App-Rak-Markdown/actions/workflows/linux.yml/badge.svg)](https://github.com/lizmat/App-Rak-Markdown/actions) [![Actions Status](https://github.com/lizmat/App-Rak-Markdown/actions/workflows/macos.yml/badge.svg)](https://github.com/lizmat/App-Rak-Markdown/actions) [![Actions Status](https://github.com/lizmat/App-Rak-Markdown/actions/workflows/windows.yml/badge.svg)](https://github.com/lizmat/App-Rak-Markdown/actions)

NAME
====

App::Rak::Markdown - convert App::Rak output to Markdown

SYNOPSIS
========

```raku
use App::Rak::Markdown;

my $rmd = App::Rak::Markdown.new;

spurt "result.md", $rmd.markdown(@output);

spurt "result.md", $rmd.run(<--unicode §love>, :tableize<unicode>);
```

DESCRIPTION
===========

The `App::Rak::Markdown` distribution provides logic to convert the output of [`App::Rak`](https://raku.land/zef:lizmat/App::Rak) to Markdown format.

This can either be done from captured output, or from a set of arguments to be sent to the `rak` command line script.

METHODS
=======

new
---

```raku
my $rmd = App::Rak::Markdown.new(
  break => '§§§',  # default: '***'
);
```

The `new` method takes 1 named argument:

### :break

The string to be used / checked for between grouped items in `rak`'s output (as documented with the `--break` argument). Defaults to `"***"`.

markdown
--------

```raku
say $rmd.markdown(@output);

my $markdown = $rmd.markdown(
  @output,
  my $items,    # store # of items seen, default: don't bother
  my $files,    # store # of files seen, default: don't bother
  my $heads,    # store # of headers seen, default: don't bother
  :headers(0),  # how many levels of headers, default: 1
  :depth<##>,   # markdown string of top headers, default: "###"
  :&tableizer,  # logic to create tables, default: none
)
```

The `markdown` method takes a number of arguments, and returns a string formatted according to Markdown rules.

It takes at least one positional argument: a list of lines of `rak` output.

It also takes the following optional positional arguments:

  * $items - where to store the # of items seen, default: don't bother

  * $files - where to store the # of files seen, default: don't bother

  * $heads - where to store the # of headers seen, default: don't bother

And takes the following optional named arguments:

  * :headers - the number of header levels, defaults to 1

  * :depth - the markdown string for the top header, default "###"

  * :tableizer - logic to create tables, default: none.

### Creating tables

If the output from `rak` is fit to create markdown tables for (e.g. the `--unicode` option, the `:tableizer` named argument can be used to indicate a `Callable` that will be called to manage creating markdown tables.

This `Callable` is expected to be called without any arguments: in that case it should return **two** lists: the first with the names of the columns, and the second with formatting info for each column. The formatting info can be specified with the following words:

  * left - align text in column to the left

  * center - center text in colum

  * right - align text in column to the right

Any other word will cause no specific aligning to be done. 

If called **with** an argument, it should return a list with the text for each column.

Some standard rak options have a dedicated tableizer, which can be invoked by name. They currently are:

  * unicode - tableize for --unicode output

run
---

```raku
say "result.md", $rmd.run(<--unicode §love>, :tableize<unicode>);
# hex | name | graph
# :- | :-: | :-:
# 1F3E9 | <b>LOVE</b> HOTEL | 🏩
# 1F48C | <b>LOVE</b> LETTER | 💌
# 1F91F | I <b>LOVE</b> YOU HAND SIGN | 🤟
```

The `run` method is effectively a wrapper around the `markdown` method, taking some extra arguments instead of the initial positional argument of `markdown`.

It either returns the Markdown string, or `Nil` if something went wrong, or if not enough lines were received from `rak` to make parsing to Markdown worthwhile.

The first positional argument is required: it should contain the arguments to be sent to `rak`.

The second optional positional argument specifies an array in which any error output should be stored in case something went wrong. This should be checked if `Nil` was returned. Defaults to "don't bother".

The third optional positional argument specifies an array in which any standard output should be stored in case not enough lines of output were obtained (see `:min-lines` named argument). This should be checked if `Nil` was returned. Defaults to "don't bother".

All other arguments that `markdown` can receive, can also be specified here:

  * $items - where to store the # of items seen, default: don't bother

  * $files - where to store the # of files seen, default: don't bother

  * $heads - where to store the # of headers seen, default: don't bother

  * :headers - the number of header levels, defaults to 1

  * :depth - the markdown string for the top header, default "###"

  * :tableizer - logic to create tables, default: none.

Additional named arguments that can be specified with the `run` method:

  * :min-lines - the minumum number of lines in output, default: 0

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/App-Rak-Markdown . Comments and Pull Requests are welcome.

If you like this module, or what I'm doing more generally, committing to a [small sponsorship](https://github.com/sponsors/lizmat/) would mean a great deal to me!

COPYRIGHT AND LICENSE
=====================

Copyright 2025 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

