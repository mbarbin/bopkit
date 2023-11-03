import type { SidebarsConfig } from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  sidebar: [
    { type: 'doc', id: 'README', label: 'Introduction' },
    { type: 'doc', id: 'stdlib/README', label: 'Stdlib' },
    {
      type: 'category', label: 'Bopboard',
      link: { type: 'doc', id: 'bopboard/README' },
      items: [
        { type: 'doc', id: 'bopboard/example/README', label: 'Examples' },
      ]
    },
    { type: 'doc', id: 'segment/README', label: '7-segment displays' },
    { type: 'doc', id: 'counter/README', label: 'Counter' },
    { type: 'doc', id: 'pulse/README', label: 'Pulse' },
  ],
};

export default sidebars;
