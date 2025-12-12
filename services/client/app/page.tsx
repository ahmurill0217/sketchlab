'use client'

import { useToast } from '@/hooks/use-toast'
import { Button } from '@/components/ui/button'
export default function Home() {
  const { toast } = useToast()

  const showToast = (
    title: string,
    description: string,
    variant: 'default' | 'destructive' | 'success' = 'default',
  ) => {
    toast({
      variant,
      title,
      description,
    })
  }

  return (
    <div className="flex items-center justify-center min-h-[calc(100vh-79.88px-186.7px)] p-4">
      <div className="max-w-[37.5rem]">
        <h1 className="text-primary text-center">🧬 Hello, Avitar!</h1>
        <p className="my-4">
          Congratulations! You've successfully launched a shiny new Avidity project from our boilerplate repo.
        </p>
        <p className="my-4">Now that you're here, don't forget to:</p>
        <ul className="list-disc text-left ml-8 my-4">
          <li>Update the README.md with your project specifics</li><li>Change the metadata in layout.tsx</li><li>Show off your creation to the team! 🚀🚀🚀</li>
        </ul>
        <p className="my-4">
          Happy coding, Avitar! May your builds be swift and your bugs be few. 🎉
        </p>
        <Button
          className="mt-12 mx-auto block"
          onClick={() => showToast('🕺🏻🎉🥳', "LET'S GOOOO!!", 'success')}
        >
          High Five! ✋
        </Button>
      </div>
    </div>
  )
}