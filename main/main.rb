# frozen_string_literal: true
require 'ruby_grammar_builder'
require 'walk_up'
require_relative walk_up_until("paths.rb")
require_relative './tokens.rb'

# 
# 
# create grammar!
# 
# 
grammar = Grammar.fromTmLanguage("./main/modified.tmLanguage.json")
grammar.name = "Lisp"
grammar.scope_name = "source.lisp"

# 
#
# Setup Grammar
#
# 
    
    grammar[:$initial_context] = [
        # new patterns
        :control,
        :constant_nonlist,
        :sharpsign_nonlist,
        :constant_list,
        :lambda_list,
        :specialform,
        :support_function,
        :function_m_nosideeffects,
        :variable_symbol,
        :mimic_function_call,
        :parens,
        
        # old patterns
        :comment,
        :block_comment,
        :string,
        :escape,
        :constant,
        :lambda_list,
        :function,
        :style_guide,
        :def_name,
        :macro,
        :symbol,
        :special_operator,
        :declaration,
        :type,
        :class,
        :condition_type,
        :package,
        :variable,
        :punctuation,
        
        :atom
    ]

# 
# Helpers
# 
    # @space
    # @spaces
    # @digit
    # @digits
    # @standard_character
    # @word
    # @word_boundary
    # @white_space_start_boundary
    # @white_space_end_boundary
    # @start_of_document
    # @end_of_document
    # @start_of_line
    # @end_of_line
    part_of_a_variable = /[a-zA-Z_][a-zA-Z_0-9]*/
    # this is really useful for keywords. eg: variableBounds[/new/] wont match "newThing" or "thingnew"
    variableBounds = ->(regex_pattern) do
        lookBehindFor(@standard_character).then(regex_pattern).lookAheadToAvoid(@standard_character)
    end
    variable = variableBounds[part_of_a_variable]
    
# 
# patterns
# 
    atom_regex = /[a-zA-Z_][\w\-]*/
    grammar[:atom] = Pattern.new(
        tag_as: "constant.language.symbol",
        match: atom_regex,
    )
    
    custom_parens = ->(pattern:nil, simple_name:nil, tag:nil) do
        PatternRange.new(
            tag_as: "meta.#{simple_name}",
            start_pattern: Pattern.new(
                Pattern.new(
                    tag_as: "punctuation.section.parens.#{simple_name} #{tag}",
                    match: /\(/,
                ).then(
                    /\s*+/
                ).then(
                    pattern
                )
            ),
            end_pattern: Pattern.new(
                tag_as: "punctuation.section.parens.#{simple_name} #{tag}",
                match: /\)/,
            ),
            includes: [
                :$initial_context
            ],
        )
    end
    
    grammar[:control] = custom_parens[
        simple_name: "control",
        tag: "keyword.control",
        pattern: Pattern.new(
            tag_as: "keyword.control.$match",
            match: /unwind-protect|throw|the|tagbody|symbol-macrolet|return-from|quote|progv|progn|multiple-value-prog1|multiple-value-call|macrolet|locally|load-time-value|let\*|let|labels|if|go|function|flet|eval-when|catch|block/,
        ),
    ]
    
    grammar[:lambda_list] = custom_parens[
        simple_name: "lambdalist",
        tag: "keyword.other.lambdalist",
        pattern: Pattern.new(
            tag_as: "punctuation.accessor keyword.other.lambdalist",
            match: /&/,
        ).then(
            tag_as: "punctuation.accessor keyword.other.lambdalist.$match",
            match: /[#:A-Za-z0-9\+\-\*\/\@\$\%\^\&\_\=\<\>\~\!\?\[\]\{\}\.]+?|whole|rest|optional|key|environment|body|aux|allow-other-keys/,
        ).lookAheadFor(/\s|\(|\)/),
    ]
    
    grammar[:specialform] = custom_parens[
        simple_name: "specialform",
        tag: "storage.type.function.specialform",
        pattern: Pattern.new(
            tag_as: "storage.type.function.specialform",
            match: /setq/,
        ).lookAheadFor(/\s|\(|\)/),
    ]
    
    grammar[:support_function] = custom_parens[
        simple_name: "support.function keyword.operator",
        tag: "support.function keyword.operator",
        pattern: Pattern.new(
            tag_as: "support.function.$match keyword.operator",
            match: /satisfies|reinitialize-instance|variable|update-instance-for-redefined-class|update-instance-for-different-class|structure|slot-unbound|slot-missing|shared-initialize|remove-method|print-object|no-next-method|no-applicable-method|method-qualifiers|make-load-form|make-instances-obsolete|make-instance|initialize-instance|function-keywords|find-method|documentation|describe-object|compute-applicable-methods|compiler-macro|class-name|change-class|allocate-instance|add-method|yes-or-no-p|y-or-n-p|write-sequence|write-char|write-byte|warn|vector-pop|use-value|use-package|unuse-package|union|unintern|unexport|terpri|tailp|substitute-if-not|substitute-if|substitute|subst-if-not|subst-if|subst|sublis|string-upcase|string-downcase|string-capitalize|store-value|sleep|signal|shadowing-import|shadow|set-syntax-from-char|set-macro-character|set-exclusive-or|set-dispatch-macro-character|set-difference|set|rplacd|rplaca|room|reverse|revappend|require|replace|remprop|remove-if-not|remove-if|remove-duplicates|remove|remhash|read-sequence|read-byte|random|provide|pprint-tabular|pprint-newline|pprint-linear|pprint-fill|nunion|nsubstitute-if-not|nsubstitute-if|nsubstitute|nsubst-if-not|nsubst-if|nsubst|nsublis|nstring-upcase|nstring-downcase|nstring-capitalize|nset-exclusive-or|nset-difference|nreverse|nreconc|nintersection|nconc|muffle-warning|method-combination-error|maphash|makunbound|ldiff|invoke-restart-interactively|invoke-restart|invoke-debugger|invalid-method-error|intersection|inspect|import|get-output-stream-string|get-macro-character|get-dispatch-macro-character|gentemp|gensym|fresh-line|fill|file-position|export|describe|delete-if-not|delete-if|delete-duplicates|delete|continue|clrhash|close|clear-input|break|abort|values|third|tenth|symbol-value|symbol-plist|symbol-function|svref|subseq|sixth|seventh|second|schar|sbit|row-major-aref|rest|readtable-case|nth|ninth|mask-field|macro-function|logical-pathname-translations|ldb|gethash|getf|get|fourth|first|find-class|fill-pointer|fifth|fdefinition|elt|eighth|compiler-macro-function|char|cdr|cddr|cdddr|cddddr|cdddar|cddar|cddadr|cddaar|cdar|cdadr|cdaddr|cdadar|cdaar|cdaadr|cdaaar|car|cadr|caddr|cadddr|caddar|cadar|cadadr|cadaar|caar|caadr|caaddr|caadar|caaar|caaadr|caaaar|bit|aref|zerop|write-to-string|write-string|write-line|write|wild-pathname-p|vectorp|vector-push-extend|vector-push|vector|values-list|user-homedir-pathname|upper-case-p|upgraded-complex-part-type|upgraded-array-element-type|unread-char|unbound-slot-instance|typep|type-of|type-error-expected-type|type-error-datum|two-way-stream-output-stream|two-way-stream-input-stream|truncate|truename|tree-equal|translate-pathname|translate-logical-pathname|tanh|tan|synonym-stream-symbol|symbolp|symbol-package|symbol-name|sxhash|subtypep|subsetp|stringp|string>=|string>|string=|string<=|string<|string\/=|string-trim|string-right-trim|string-not-lessp|string-not-greaterp|string-not-equal|string-lessp|string-left-trim|string-greaterp|string-equal|string|streamp|stream-external-format|stream-error-stream|stream-element-type|standard-char-p|stable-sort|sqrt|special-operator-p|sort|some|software-version|software-type|slot-value|slot-makunbound|slot-exists-p|slot-boundp|sinh|sin|simple-vector-p|simple-string-p|simple-condition-format-control|simple-condition-format-arguments|simple-bit-vector-p|signum|short-site-name|set-pprint-dispatch|search|scale-float|round|restart-name|rename-package|rename-file|rem|reduce|realpart|realp|readtablep|read-preserving-whitespace|read-line|read-from-string|read-delimited-list|read-char-no-hang|read-char|read|rationalp|rationalize|rational|rassoc-if-not|rassoc-if|rassoc|random-state-p|proclaim|probe-file|print-not-readable-object|print|princ-to-string|princ|prin1-to-string|prin1|pprint-tab|pprint-indent|pprint-dispatch|pprint|position-if-not|position-if|position|plusp|phase|peek-char|pathnamep|pathname-version|pathname-type|pathname-name|pathname-match-p|pathname-host|pathname-directory|pathname-device|pathname|parse-namestring|parse-integer|pairlis|packagep|package-used-by-list|package-use-list|package-shadowing-symbols|package-nicknames|package-name|package-error-package|output-stream-p|open-stream-p|open|oddp|numerator|numberp|null|nthcdr|notevery|notany|not|next-method-p|nbutlast|namestring|name-char|mod|mismatch|minusp|min|merge-pathnames|merge|member-if-not|member-if|member|max|maplist|mapl|mapcon|mapcar|mapcan|mapc|map-into|map|make-two-way-stream|make-synonym-stream|make-symbol|make-string-output-stream|make-string-input-stream|make-string|make-sequence|make-random-state|make-pathname|make-package|make-load-form-saving-slots|make-list|make-hash-table|make-echo-stream|make-dispatch-macro-character|make-condition|make-concatenated-stream|make-broadcast-stream|make-array|macroexpand-1|macroexpand|machine-version|machine-type|machine-instance|lower-case-p|long-site-name|logxor|logtest|logorc2|logorc1|lognot|lognor|lognand|logior|logical-pathname|logeqv|logcount|logbitp|logandc2|logandc1|logand|log|load-logical-pathname-translations|load|listp|listen|list-length|list-all-packages|list\*|list|lisp-implementation-version|lisp-implementation-type|length|ldb-test|lcm|last|keywordp|isqrt|intern|interactive-stream-p|integerp|integer-length|integer-decode-float|input-stream-p|imagpart|identity|host-namestring|hash-table-test|hash-table-size|hash-table-rehash-threshold|hash-table-rehash-size|hash-table-p|hash-table-count|graphic-char-p|get-universal-time|get-setf-expansion|get-properties|get-internal-run-time|get-internal-real-time|get-decoded-time|gcd|functionp|function-lambda-expression|funcall|ftruncate|fround|format|force-output|fmakunbound|floor|floatp|float-sign|float-radix|float-precision|float-digits|float|finish-output|find-symbol|find-restart|find-package|find-if-not|find-if|find-all-symbols|find|file-write-date|file-string-length|file-namestring|file-length|file-error-pathname|file-author|ffloor|fceiling|fboundp|expt|exp|every|evenp|eval|equalp|equal|eql|eq|ensure-generic-function|ensure-directories-exist|enough-namestring|endp|encode-universal-time|ed|echo-stream-output-stream|echo-stream-input-stream|dribble|dpb|disassemble|directory-namestring|directory|digit-char-p|digit-char|deposit-field|denominator|delete-package|delete-file|decode-universal-time|decode-float|count-if-not|count-if|count|cosh|cos|copy-tree|copy-symbol|copy-structure|copy-seq|copy-readtable|copy-pprint-dispatch|copy-list|copy-alist|constantp|constantly|consp|cons|conjugate|concatenated-stream-streams|concatenate|compute-restarts|complexp|complex|complement|compiled-function-p|compile-file-pathname|compile-file|compile|coerce|code-char|clear-output|class-of|cis|characterp|character|char>=|char>|char=|char<=|char<|char\/=|char-upcase|char-not-lessp|char-not-greaterp|char-not-equal|char-name|char-lessp|char-int|char-greaterp|char-equal|char-downcase|char-code|cerror|cell-error-name|ceiling|call-next-method|byte-size|byte-position|byte|butlast|broadcast-stream-streams|boundp|both-case-p|boole|bit-xor|bit-vector-p|bit-orc2|bit-orc1|bit-not|bit-nor|bit-nand|bit-ior|bit-eqv|bit-andc2|bit-andc1|bit-and|atom|atanh|atan|assoc-if-not|assoc-if|assoc|asinh|asin|ash|arrayp|array-total-size|array-row-major-index|array-rank|array-in-bounds-p|array-has-fill-pointer-p|array-element-type|array-displacement|array-dimensions|array-dimension|arithmetic-error-operation|arithmetic-error-operands|apropos-list|apropos|apply|append|alphanumericp|alpha-char-p|adjustable-array-p|adjust-array|adjoin|acosh|acos|acons|abs|>=|>|=|<=|<|1-|1\+|\/=|\/|-|\+|\*/,
        ).lookAheadFor(/\s|\(|\)/),
    ]
    
    grammar[:function_m_nosideeffects] = custom_parens[
        simple_name: "function.m.nosideeffects",
        tag: "storage.type.function.m.nosideeffects",
        pattern: Pattern.new(
            tag_as: "storage.type.function.m.nosideeffects.$match",
            match: /with-standard-io-syntax|with-slots|with-simple-restart|with-package-iterator|with-hash-table-iterator|with-condition-restarts|with-compilation-unit|with-accessors|when|unless|typecase|time|step|shiftf|setf|rotatef|return|restart-case|restart-bind|psetf|prog2|prog1|prog\*|prog|print-unreadable-object|pprint-logical-block|pprint-exit-if-list-exhausted|or|nth-value|multiple-value-setq|multiple-value-list|multiple-value-bind|make-method|loop|lambda|ignore-errors|handler-case|handler-bind|formatter|etypecase|dotimes|dolist|do-symbols|do-external-symbols|do-all-symbols|do\*|do|destructuring-bind|defun|deftype|defstruct|defsetf|defpackage|defmethod|defmacro|define-symbol-macro|define-setf-expander|define-condition|define-compiler-macro|defgeneric|defconstant|defclass|declaim|ctypecase|cond|call-method|assert|and/,
        ).lookAheadFor(/\s|\(|\)/),
    ]
    
    grammar[:variable_symbol] = custom_parens[
        simple_name: "symbol",
        tag: "entity.name.variable.symbol",
        pattern: Pattern.new(
            tag_as: "entity.name.variable.symbol",
            match: /\:[#:A-Za-z0-9\+\-\*\/\@\$\%\^\&\_\=\<\>\~\!\?\[\]\{\}\.]+?/,
        ).lookAheadFor(/\s|\(|\)/),
    ]
    
    grammar[:constant_nonlist] = Pattern.new(
        lookBehindFor(/^|\s|\(|,@|,\.|,/).then(
            match: /'|`/,
            tag_as: "punctuation.accessor variable.other.constant.singlequote",
        ).lookAheadFor(/\S/).then(
            match: /[^() ]+/,
            tag_as: "variable.other.constant.singlequote",
        )
    )
    
    grammar[:sharpsign_nonlist] = Pattern.new(
        lookBehindFor(/^|\s|\(|,@|,\.|,/).then(
            match: /\#\*|\#0\*|\#(?:\+|-)|\#(?:'|,|\.|c|C|s|S|p|P)/,
            tag_as: "punctuation.accessor variable.other.constant.sharpsign",
        ).lookAheadFor(/\S/).then(
            match: /[^() ]+/,
            tag_as: "variable.other.constant.sharpsign",
        )
    )
    
    grammar[:constant_list] = PatternRange.new(
        tag_as: "meta.constant",
        start_pattern: Pattern.new(
            lookBehindFor(/^|\s|\(|,@|,\.|,/).then(
                match: /'|`/,
                tag_as: "variable.other.constant.singlequote",
            ).then(
                match: "(",
                tag_as: "punctuation.section.parens.constant variable.other.constant",
            )
        ),
        end_pattern: Pattern.new(
            tag_as: "punctuation.section.parens.constant variable.other.constant",
            match: /\)/,
        ),
        includes: [
            :$initial_context
        ],
    )
    
    grammar[:mimic_function_call] = PatternRange.new(
        tag_as: "meta.parens.named.unknown",
        start_pattern: Pattern.new(
            Pattern.new(
                tag_as: "punctuation.section.parens.named.unknown entity.name.function.punctuation",
                match: /\(/,
            ).then(
                tag_as: "entity.name.function",
                match: atom_regex,
            )
        ),
        end_pattern: Pattern.new(
            tag_as: "punctuation.section.parens.unknown entity.name.function.punctuation",
            match: /\)/,
        ),
        includes: [
            :$initial_context
        ],
    )
    
    grammar[:parens] = PatternRange.new(
        tag_as: "meta.parens.unknown",
        start_pattern: Pattern.new(
            tag_as: "punctuation.section.parens.unknown",
            match: /\(/,
        ),
        end_pattern: Pattern.new(
            tag_as: "punctuation.section.parens.unknown",
            match: /\)/,
        ),
        includes: [
            :$initial_context
        ],
    )
    
    

#
# Save
#
name = "lisp"
grammar.save_to(
    syntax_name: name,
    syntax_dir: "./autogenerated",
    tag_dir: "./autogenerated",
)