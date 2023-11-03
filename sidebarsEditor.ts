import type { SidebarsConfig } from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  sidebar: [
    { type: 'doc', id: 'README', label: 'Introduction' },
    { type: 'doc', id: 'vscode/README', label: 'Visual Studio Code' },
    { type: 'doc', id: 'gtksourceview/README', label: 'GtkSourceView' }
  ],
};

export default sidebars;
