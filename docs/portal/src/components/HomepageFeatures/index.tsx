import type {ReactNode} from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import Heading from '@theme/Heading';
import {Calculator, Microscope, ScrollText, ShieldCheck} from 'lucide-react';
import styles from './styles.module.css';

type FeatureItem = {
  title: string;
  Icon: React.ComponentType<{size?: number; strokeWidth?: number; className?: string}>;
  description: ReactNode;
  link: string;
};

const FeatureList: FeatureItem[] = [
  {
    title: 'Math Transparency',
    Icon: Calculator,
    link: '/guides/project-overview#math-transparency',
    description: (
      <>
        Every dice roll and modifier is logged with full metadata. Verify the 
        mathematical integrity of the simulation engine down to the individual 1d20.
      </>
    ),
  },
  {
    title: 'Simulation Lab',
    Icon: Microscope,
    link: '/specs/simulation-dashboard/dashboard',
    description: (
      <>
        Run batch simulations directly from the dashboard. Visualize DPR trends, 
        survival rates, and win distributions across different builds.
      </>
    ),
  },
  {
    title: 'Class Specifications',
    Icon: ScrollText,
    link: '/specs',
    description: (
      <>
        Detailed requirements for 2024 D&D mechanics. From Weapon Masteries to 
        Fighter maneuvers, every feature is documented using OpenSpec.
      </>
    ),
  },
  {
    title: 'Design Governance',
    Icon: ShieldCheck,
    link: '/decisions',
    description: (
      <>
        Architecture Decision Records (ADRs) document every technical choice, 
        ensuring the simulator remains robust, modular, and maintainable.
      </>
    ),
  },
];

function Feature({title, Icon, description, link}: FeatureItem) {
  return (
    <div className={clsx('col col--3')}>
      <Link to={link} className={styles.featureLink}>
        <div className="text--center">
          <Icon size={64} strokeWidth={1.5} className={styles.featureIcon} />
        </div>
        <div className="text--center padding-horiz--md">
          <Heading as="h3">{title}</Heading>
          <p>{description}</p>
        </div>
      </Link>
    </div>
  );
}

export default function HomepageFeatures(): ReactNode {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
