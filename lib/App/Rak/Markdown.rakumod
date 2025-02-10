# Defaults for highlighting on terminals
my constant BON  = "\e[1m";   # BOLD ON
my constant BOFF = "\e[22m";  # BOLD OFF

# Markdown escapes
my sub escape($_) {
    .trans(
     ('<',    '>',BON,  BOFF,'[','$', '*'  )
     =>
     ('\\<','\\>','<b>','</b>','\\[','<span>$</span>', '<span>*</span>')
    )
}

# Convert column alignment word to markdown divider spec
my constant %word2div =
  left   => ':-',
  center => ':-:',
  right  => '-:'
;
my sub word2div($_) { %word2div{$_} // '-' }

# Return tableizer callable or Nil
my sub tableizer($tableizer) {
    $tableizer
      ?? $tableizer ~~ Callable
        ?? $tableizer
        !! $tableizer eq <unicode frequencies unique>.any
          ?? ::("&$tableizer")
          !! die "Unknown tableizer: $tableizer"
      !! Nil
}

# Tableizer for --unicode
my multi sub unicode() { <hex name graph>, <left left center> }
my multi sub unicode($_) {
    my str @words = .words;
    (@words.head, @words[1..*-2].join(" "), @words.tail)
}

# Tableizer for --frequencies
my multi sub frequencies()   { <freq value>, <right left> }
my multi sub frequencies($_) { .split(":", 2)         }

# Tableizer for --unique
my multi sub unique()   { <value>, <left> }
my multi sub unique($_) { ($_,)           }

class App::Rak::Markdown:ver<0.0.2>:auth<zef:lizmat> {
    has str $.break = "***";

    method run(App::Rak::Markdown:D:
           @args,
          :@err = my str @,
          :@out = my str @,
          :$items is raw = my int $,
          :$files is raw = my int $,
          :$heads is raw = my int $,
      int :$min-lines,
          :$sort
    ) {
        my $proc := run 'rak', @args, "--break=$!break", :out, :err;

        # Alas, something went awry
        if $proc.exitcode {
            @err = $proc.err.lines;
            return Nil;
        }

        # Not enough lines to process
        my str @output = $proc.out.lines;
        if @output < $min-lines {
            @out = @output;
            Nil
        }

        # Enough to process, go do it!
        else {
            if $sort {
                @output = $sort ~~ Bool
                  ?? @output.sort
                  !! @output.sort($sort);
            }
            self.markdown(@output, :$items, :$files, :$heads, |%_)
        }
    }

    method markdown(App::Rak::Markdown:D:
           @raw,
          :$items is raw = my int $,
          :$files is raw = my int $,
          :$heads is raw = my int $,
      Int :$headers = 1,
      str :$depth   = "###",
          :$tableizer,
    ) {
        my Str @lines;  # must be Str until 2025.02
        my str $last-header      = "";
        my str $break            = $!break;
        my int $expecting-header = $headers;

        my &tableize = tableizer($tableizer);
        if &tableize {
            my ($header, $divider) = tableize();
            @lines.push($header.join(" | "));
            @lines.push($divider.map(&word2div).join(" | "));
        }

        for @raw -> $line {
            if $expecting-header {
                my @parts  = $line.split("/",$expecting-header);
                my $header = @parts.shift;
                if $header ne $last-header {
                    ++$heads;
                    @lines.push("___") if $last-header;
                    $last-header = $header;
                    @lines.push(escape "$depth $header");
                }

                ++$files;
                my str $deeper = $depth;
                for @parts {
                    $deeper ~= "#";
                    @lines.push(escape "$deeper $_");
                }
                $expecting-header = False;
            }
            elsif $line eq $break {
                @lines.tail .= chomp("\\");
                @lines.push("");
                $expecting-header = $headers;
            }
            elsif $line {
                ++$items;
                @lines.push(escape &tableize
                  ?? tableize($line).join(" | ")
                  !! "$line\\"
                );
            }
            else {
                @lines.tail .= chomp("\\");
                @lines.push("");
            }
        }

        @lines.tail .= chomp("\\");
        @lines.push("").join("\n")
    }
}

# vim: expandtab shiftwidth=4
