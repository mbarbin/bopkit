/// https://docusaurus.io/docs/sidebar

// @ts-check

/** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
const sidebars = {
  sidebar: [
    { type: 'doc', id: 'README', label: 'Introduction' },
    { type: 'category', label: 'Bopboard',
      link: { type: 'doc', id: 'bopboard/README' },
      items: [
        { type: 'doc', id: 'bopboard/example/README', label: 'Examples' },
      ]
    }
  ],
};

module.exports = sidebars;
