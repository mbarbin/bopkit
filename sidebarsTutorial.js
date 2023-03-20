/// https://docusaurus.io/docs/sidebar

// @ts-check

/** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
const sidebars = {
  sidebar: [
    { type: 'doc', id: 'README', label:'Introduction' },
    { type: 'doc', id: 'hello-world/README', label:'Hello world' },
    { type: 'category', label: 'Binary Decision Diagrams',
      link: { type: 'doc', id: 'bdd/README' },
      items: [
        { type: 'doc', id: 'bdd/partial_specification', label:'Partial specification' },
        { type: 'doc', id: 'bdd/division/README', label:'Division with bopkit bdd' },
      ]
    },
    { type: 'doc', id: 'misc/README', label:'Misc' },
  ],
};

module.exports = sidebars;
