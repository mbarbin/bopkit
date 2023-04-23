/// https://docusaurus.io/docs/sidebar

// @ts-check

/** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
const sidebars = {
  sidebar: [
    { type: 'doc', id: 'README', label:'Introduction' },
    { type: 'doc', id: 'digital-watch/README', label:'Digital Watch' },
    { type: 'category', label: 'Visa',
      link: { type: 'doc', id: 'visa/README' },
      items: [
        { type: 'doc', id: 'visa/doc/introduction', label:'Introduction' },
        { type: 'doc', id: 'visa/doc/assembler', label:'Assembler' },
        { type: 'doc', id: 'visa/editor/vscode/README', label:'Editor' },
        { type: 'doc', id: 'visa/doc/calendar', label:'Calendar' },
        { type: 'doc', id: 'visa/doc/circuit', label:'Circuit' },
        { type: 'doc', id: 'visa/doc/tests', label:'Tests' },
      ]
    },
    { type: 'doc', id: 'subleq/README', label:'Subleq' },
    { type: 'doc', id: 'wml/README', label:'Wml' },
  ],
};

module.exports = sidebars;
