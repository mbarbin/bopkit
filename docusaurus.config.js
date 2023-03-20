// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

const lightCodeTheme = require('prism-react-renderer/themes/github');
const darkCodeTheme = require('prism-react-renderer/themes/dracula');

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
        copyright: `Copyright © ${new Date().getFullYear().toString()} Mathieu Barbin. Built with Docusaurus.`,
      },
      prism: {
        theme: lightCodeTheme,
        darkTheme: darkCodeTheme,
      },
    }),
};

module.exports = config;
