import { SimulationDashboard } from './components/Simulation'

function App() {
  const version = __APP_VERSION__;
  return (
    <div style={{ padding: '2rem', maxWidth: '1200px', margin: '0 auto' }}>
      <meta name="build-time" content={version} />
      <h1>Simulation Laboratory</h1>
      <p>
        <a href="/docs">View Documentation</a>
      </p>
      <SimulationDashboard />
      <footer style={{ marginTop: '4rem', padding: '1rem', borderTop: '1px solid #eee', fontSize: '0.7rem', color: '#999', textAlign: 'center' }}>
        Build Version: {version}
      </footer>
    </div>
  )
}
export default App
