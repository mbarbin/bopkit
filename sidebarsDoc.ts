import type { SidebarsConfig } from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  sidebar: [
    { type: 'doc', id: 'README', label: 'Introduction' },
    {
      type: 'category', label: 'Language Reference',
      link: { type: 'doc', id: 'reference/README' },
      items: [
        { type: 'doc', id: 'reference/includes', label: 'Includes' },
        { type: 'doc', id: 'reference/parameters', label: 'Parameters' },
        { type: 'doc', id: 'reference/memories', label: 'Memories' },
        { type: 'doc', id: 'reference/external-blocks', label: 'External blocks' },
        { type: 'doc', id: 'reference/blocks', label: 'Blocks' },
        { type: 'doc', id: 'reference/signals-and-buses', label: 'Signals and buses' },
      ]
    },
    { type: 'link', href: '/editor/', label: 'Setting up your editor' },
  ],
};

export default sidebars;
