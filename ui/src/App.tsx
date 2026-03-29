import { SimulationDashboard } from './components/Simulation'

function App() {
  return (
    <div style={{ padding: '2rem', maxWidth: '1200px', margin: '0 auto' }}>
      <h1>Simulation Laboratory</h1>
      <p>
        <a href="/docs">View Documentation</a>
      </p>
      <SimulationDashboard />
    </div>
  )
}

export default App
