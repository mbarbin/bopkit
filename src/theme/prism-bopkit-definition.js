Prism.languages.bopkit = {
    'comment': [
        {
            pattern: /(^|[^\\])\/\*[\s\S]*?(?:\*\/|$)/,
            lookbehind: true,
            greedy: true
        },
        {
            pattern: /(^|[^\\:])\/\/.*/,
            lookbehind: true,
            greedy: true
        }
    ],
    'directive': {
	pattern: /\B#\w+/,
	alias: 'property'
    },
    'primitive': {
	pattern: /\b(?:Not|And|Or|Id|Xor|Mux|Reg|Reg1|RegEn|Reg1En|Clock|Gnd|Vdd|Main)\b/,
	alias: 'symbol'
    },
    'string': {
        pattern: /(["'])(?:\\(?:\r\n|[\s\S])|(?!\1)[^\\\r\n])*\1/,
        greedy: true
    },
    'keyword': /\b(?:if|then|else|for|to|where|end|with|unused|text|file|RAM|ROM|external|#include|#define)\b/,
    'function': /\b(?:def|log|max|min|mod)\b/,
    'number': /\b0x[\da-f]+\b|(?:\b\d+(?:\.\d*)?|\B\.\d+)(?:e[+-]?\d+)?/i,
    'operator': /[<>]=?|[!=]=?=?|--?|\+\+?|&&?|\|\|?|[?*/~^%]/,
    'punctuation': /[{}[\];(),.:]/
};
