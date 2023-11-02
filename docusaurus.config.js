// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

const {themes} = require('prism-react-renderer');
const lightCodeTheme = themes.github;
const darkCodeTheme = themes.dracula;

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Bopkit',
  tagline: 'An educational project for digital circuits programming',
  favicon: 'img/favicon.ico',

  // Set the production url of your site here
  url: 'https://mbarbin.github.io',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/bopkit/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'mbarbin', // Usually your GitHub org/user name.
  projectName: 'bopkit', // Usually your repo name.

  trailingSlash: true,

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  // Even if you don't use internalization, you can use this field to set useful
  // metadata like html lang. For example, if your site is Chinese, you may want
  // to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          path:'doc',
          routeBasePath: 'doc',
          sidebarPath: require.resolve('./sidebarsDoc.js'),
          editUrl: 'https://github.com/mbarbin/bopkit/tree/main/',
        },
        blog: false,
        theme: {
          customCss: [
            require.resolve('./src/css/custom.css'),
          ]
        },
      }),
    ],
  ],

  plugins: [
    [
      '@docusaurus/plugin-content-docs',
      {
        id: 'tutorial',
        path: 'tutorial',
        routeBasePath: 'tutorial',
        sidebarPath: require.resolve('./sidebarsTutorial.js'),
      },
    ],
    [
      '@docusaurus/plugin-content-docs',
      {
        id: 'stdlib',
        path: 'stdlib',
        routeBasePath: 'stdlib',
        sidebarPath: require.resolve('./sidebarsStdlib.js'),
      },
    ],
    [
      '@docusaurus/plugin-content-docs',
      {
        id: 'project',
        path: 'project',
        routeBasePath: 'project',
        sidebarPath: require.resolve('./sidebarsProject.js'),
      },
    ],
    [
      '@docusaurus/plugin-content-docs',
      {
        id: 'editor',
        path: 'editor',
        routeBasePath: 'editor',
        sidebarPath: require.resolve('./sidebarsEditor.js'),
      },
    ],
  ],

  markdown: {
    mermaid: true,
  },

  themes: ['@docusaurus/theme-mermaid'],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      image: 'img/favicon.ico',
      navbar: {
        hideOnScroll: true,
        title: 'Bopkit',
        logo: {
          alt: 'Bopkit Logo',
          src: 'img/ladybug.png',
        },
        items: [
          {to: '/doc/', label: 'Docs', position: 'left'},
          {to: '/tutorial/', label: 'Tutorials', position: 'left'},
          {to: '/stdlib/', label: 'Stdlib', position: 'left'},
          {to: '/project/', label: 'Projects', position: 'left'},
          // odoc deployment not ready yet.
          // {href: 'https://mbarbin.github.io/bopkit/odoc/', label: 'API', position: 'left'},
          {
            href: 'https://github.com/mbarbin/bopkit',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      docs: {
        sidebar: {
          hideable: true,
          autoCollapseCategories: true,
        },
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Docs',
            items: [
              { label: 'Docs', to: '/doc/' },
              { label: 'Tutorials', to: '/tutorial/' },
              { label: 'Stdlib', to: '/stdlib/' },
              { label: 'Projects', to: '/project/' },
            ],
          },
          {
            title: 'More',
            items: [
              {
                label: 'GitHub',
                href: 'https://github.com/mbarbin/bopkit',
              },
            ],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear().toString()} Mathieu Barbin. Built with Docusaurus v3.`,
      },
      prism: {
        theme: lightCodeTheme,
        darkTheme: darkCodeTheme,
        additionalLanguages: ['bash', 'diff', 'json', 'ocaml'],
      },
      algolia: {
        // The application ID provided by Algolia
        appId: 'JE75IL1USH',
        // Public API key: it is safe to commit it
        apiKey: 'eae53ef881468106c32a10489ea5cd97',
        indexName: 'bopkit',
        // Optional: see doc section below
        contextualSearch: true,
        // Optional: Specify domains where the navigation should occur through
        // window.location instead on history.push. Useful when our Algolia
        // config crawls multiple documentation sites and we want to navigate
        // with window.location.href to them.
        // externalUrlRegex: 'external\\.com|domain\\.com',
        // Optional: Replace parts of the item URLs from Algolia. Useful when
        // using the same search index for multiple deployments using a
        // different baseUrl. You can use regexp or string in the `from` param.
        // For example: localhost:3000 vs myCompany.com/docs
        // replaceSearchResultPathname: {
        //  from: '/docs/', // or as RegExp: /\/docs\//
        //  to: '/',
        // },
        // Optional: Algolia search parameters
        searchParameters: {},
        // Optional: path for search page that enabled by default (`false` to disable it)
        searchPagePath: 'search',
        //... other Algolia params
      },
      }),
};

module.exports = config;
