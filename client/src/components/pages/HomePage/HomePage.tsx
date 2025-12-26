import { Button } from '@ui/button';
import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from '@ui/card';

export const HomePage = () => (
  <main className="min-h-screen flex flex-col items-center justify-center gap-8 p-8 bg-background">
    <div className="text-center space-y-2">
      <h1 className="text-4xl font-bold tracking-tight">MERN Template</h1>
      <p className="text-muted-foreground">
        Vite + React + TypeScript + Tailwind + shadcn/ui
      </p>
    </div>

    <Card className="w-full max-w-md">
      <CardHeader>
        <CardTitle>Bienvenue</CardTitle>
        <CardDescription>
          Template prêt à l&apos;emploi avec les meilleures pratiques
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="flex flex-wrap gap-2">
          <Button>Primary</Button>
          <Button variant="secondary">Secondary</Button>
          <Button variant="destructive">Destructive</Button>
          <Button variant="outline">Outline</Button>
          <Button variant="ghost">Ghost</Button>
          <Button variant="link">Link</Button>
        </div>
      </CardContent>
      <CardFooter>
        <p className="text-sm text-muted-foreground">
          Commencez par éditer <code className="bg-muted px-1 rounded">src/App.tsx</code>
        </p>
      </CardFooter>
    </Card>
  </main>
);
