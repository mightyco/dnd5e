import type {ReactNode} from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import HomepageFeatures from '@site/src/components/HomepageFeatures';
import Heading from '@theme/Heading';

import styles from './index.module.css';

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <header className={clsx('hero hero--primary', styles.heroBanner)}>
      <div className="container">
        <Heading as="h1" className="hero__title">
          {siteConfig.title}
        </Heading>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
        <div className={styles.buttons}>
          <Link
            className="button button--secondary button--lg"
            to="/specs/simulation-dashboard/dashboard"
            style={{ marginRight: '1rem' }}>
            Open Live Dashboard 📊
          </Link>
          <Link
            className="button button--secondary button--outline button--lg"
            to="/decisions">
            View ADRs
          </Link>
        </div>
      </div>
    </header>
  );
}

function SkillsSection() {
  return (
    <section className={styles.skills}>
      <div className="container">
        <Heading as="h2" className="text--center">
          Project Governance
        </Heading>
        <p className="text--center">
          Gemini CLI skills used to maintain the mathematical and architectural integrity of the simulator.
        </p>
        <div className={styles.skillGrid} style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '1rem', marginTop: '2rem' }}>
          <div className={styles.skillCard} style={{ padding: '1rem', border: '1px solid #ddd', borderRadius: '8px' }}>
            <code>/design:adr</code>
            <p>Document architectural choices using the MADR format.</p>
          </div>
          <div className={styles.skillCard} style={{ padding: '1rem', border: '1px solid #ddd', borderRadius: '8px' }}>
            <code>/design:spec</code>
            <p>Formalize requirements with RFC 2119 standards.</p>
          </div>
          <div className={styles.skillCard} style={{ padding: '1rem', border: '1px solid #ddd', borderRadius: '8px' }}>
            <code>/design:plan</code>
            <p>Decompose specifications into GitHub issues.</p>
          </div>
        </div>
      </div>
    </section>
  );
}

export default function Home(): ReactNode {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={siteConfig.title}
      description="D&D 2024 Combat Simulator - Scientific analysis of game mechanics with built-in design governance.">
      <HomepageHeader />
      <main>
        <HomepageFeatures />
        <SkillsSection />
      </main>
    </Layout>
  );
}
