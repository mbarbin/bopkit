import type { SidebarsConfig } from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  sidebar: [
    { type: 'doc', id: 'README', label: 'Introduction' },
    { type: 'doc', id: 'hello-world/README', label: 'Hello world' },
    {
      type: 'category', label: 'Binary Decision Diagrams',
      link: { type: 'doc', id: 'bdd/README' },
      items: [
        { type: 'doc', id: 'bdd/partial_specification', label: 'Partial specification' },
        { type: 'doc', id: 'bdd/division/README', label: 'Division with bopkit bdd' },
      ]
    },
    { type: 'doc', id: 'misc/README', label: 'Misc' },
  ],
};

export default sidebars;
