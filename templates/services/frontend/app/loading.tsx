'use client'

import { Loader2 } from 'lucide-react'

const Loader: React.FC = () => (
  <div className="min-h-screen flex items-center justify-center text-center">
    <Loader2 className="animate-spin w-16 h-16 mx-auto text-primary" />
  </div>
)

export default Loader
