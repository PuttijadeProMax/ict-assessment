import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  // Allow a phone on the same network to open the public assessment URL.
  server: { host: true },
})
