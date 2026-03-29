import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

// ============================================================
// CONFIGURE THESE VALUES FOR YOUR PROJECT
// ============================================================
const PROJECT_TITLE = 'D&D 2024 Combat Simulator';
const PROJECT_TAGLINE = 'Scientific analysis of Dungeons & Dragons mechanics.';
const GITHUB_URL = 'https://github.com/mightyco/dnd5e';
const SITE_URL = 'https://mightyco.github.io';
const BASE_URL = '/dnd5e/';
// ============================================================

const config: Config = {
  title: PROJECT_TITLE,
  tagline: PROJECT_TAGLINE,
  favicon: 'img/favicon.ico',

  future: {
    v4: true,
  },

  url: SITE_URL,
  baseUrl: BASE_URL,

  onBrokenLinks: 'warn',
  onBrokenMarkdownLinks: 'warn',

  markdown: {
    format: 'detect',
    mermaid: true,
  },

  themes: ['@docusaurus/theme-mermaid'],

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          path: '../docs-generated',
          sidebarPath: './sidebars.ts',
          routeBasePath: '/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    colorMode: {
      respectPrefersColorScheme: true,
    },
    navbar: {
      title: PROJECT_TITLE,
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'guidesSidebar',
          position: 'left',
          label: 'Overview',
        },
        {
          type: 'docSidebar',
          sidebarId: 'decisionsSidebar',
          position: 'left',
          label: 'Decisions (ADRs)',
        },
        {
          type: 'docSidebar',
          sidebarId: 'specsSidebar',
          position: 'left',
          label: 'Specifications',
        },
        {
          href: GITHUB_URL,
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Simulator Resources',
          items: [
            {
              label: 'Project Overview',
              to: '/guides/project-overview',
            },
            {
              label: 'Architecture Decisions',
              to: '/decisions',
            },
            {
              label: 'Specifications',
              to: '/specs',
            },
            {
              label: 'Live Dashboard',
              to: '/specs/simulation-dashboard/dashboard',
            },
          ],
        },
        {
          title: 'More',
          items: [
            {
              label: 'GitHub',
              href: GITHUB_URL,
            },
          ],
        },
      ],
      copyright: `Copyright \u00A9 ${new Date().getFullYear()} D&D 2024 Combat Simulator. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['go', 'bash', 'yaml', 'markdown'],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
