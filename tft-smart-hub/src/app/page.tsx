export default function HomePage() {
  return (
    <main className="min-h-screen bg-white text-gray-900">
      {/* Header */}
      <header className="sticky top-0 z-40 border-b bg-white/80 backdrop-blur">
        <div className="mx-auto flex max-w-7xl items-center justify-between px-6 py-4">
          <a href="/" className="flex items-center gap-3">
            <Logo className="h-8 w-8" />
            <span className="text-lg font-semibold tracking-tight">TFT Smart Hub</span>
          </a>
          <nav className="hidden items-center gap-6 md:flex">
            <a href="/recommend" className="text-sm text-gray-700 hover:text-gray-900">Recommend</a>
            <a href="/champions" className="text-sm text-gray-700 hover:text-gray-900">Champions</a>
            <a href="/items" className="text-sm text-gray-700 hover:text-gray-900">Items</a>
            <a href="/comps/official" className="text-sm text-gray-700 hover:text-gray-900">Comps</a>
          </nav>
          <div className="flex items-center gap-3">
            <a href="/login" className="rounded-xl border px-3 py-1.5 text-sm font-medium hover:bg-gray-50">Log in</a>
            <a href="/recommend" className="hidden rounded-xl bg-gray-900 px-3 py-1.5 text-sm font-medium text-white hover:bg-black md:inline-block">Get Started</a>
          </div>
        </div>
      </header>

      {/* Hero */}
      <section className="relative overflow-hidden">
        <div className="pointer-events-none absolute inset-0 -z-10 bg-[radial-gradient(1000px_400px_at_50%_-20%,#e5e7eb,transparent)]" />
        <div className="mx-auto max-w-5xl px-6 py-20 text-center">
          <div className="mx-auto mb-6 flex h-14 w-14 items-center justify-center rounded-2xl border bg-white shadow-sm">
            <Logo className="h-7 w-7" />
          </div>
          <h1 className="text-4xl font-semibold tracking-tight sm:text-5xl">
            Personalized TFT composition <span className="underline decoration-gray-300 underline-offset-8">recommendations</span>
          </h1>
          <p className="mx-auto mt-4 max-w-2xl text-balance text-gray-600">
            Input your current board and get achievable, high win‑rate comps that align with your items, traits, and augments.
          </p>
          <div className="mt-8 flex items-center justify-center gap-3">
            <a href="/recommend" className="rounded-xl bg-gray-900 px-5 py-3 text-sm font-medium text-white hover:bg-black">Try the Recommender</a>
            <a href="/comps/official" className="rounded-xl border px-5 py-3 text-sm font-medium hover:bg-gray-50">Browse Official Comps</a>
          </div>
        </div>
      </section>

      {/* Features */}
      <section className="mx-auto max-w-6xl px-6 pb-20">
        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          <FeatureCard
            title="High win‑rate"
            desc="Backed by real match statistics: win rate, average placement, and popularity per patch."
          />
          <FeatureCard
            title="Relevant to your board"
            desc="Reuses your current units and traits to minimize pivots and roll cost."
          />
          <FeatureCard
            title="Actually achievable"
            desc="Estimates shop odds, cost curve, and rare requirements to avoid unrealistic suggestions."
          />
          <FeatureCard
            title="Personalized context"
            desc="Takes items, emblems, and augments into account so you don’t waste current advantages."
          />
          <FeatureCard
            title="Split comp library"
            desc="Official (statistical) comps and user‑created guides are organized in separate views."
          />
          <FeatureCard
            title="Patch aware"
            desc="Champions, traits, and items are versioned per patch, so data stays consistent."
          />
        </div>
      </section>

      {/* CTA */}
      <section className="border-t bg-gray-50">
        <div className="mx-auto max-w-6xl px-6 py-14 text-center">
          <h2 className="text-2xl font-semibold tracking-tight">Ready to climb?</h2>
          <p className="mt-2 text-gray-600">Start with your current board and we’ll guide you to the best achievable comps.</p>
          <a href="/recommend" className="mt-6 inline-block rounded-xl bg-gray-900 px-5 py-3 text-sm font-medium text-white hover:bg-black">Open Recommender</a>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t">
        <div className="mx-auto flex max-w-7xl items-center justify-between px-6 py-6 text-sm text-gray-500">
          <p>© {new Date().getFullYear()} TFT Smart Hub</p>
          <p>Powered by Riot Games APIs · Not affiliated with Riot Games</p>
        </div>
      </footer>
    </main>
  );
}

function FeatureCard({ title, desc }: { title: string; desc: string }) {
  return (
    <div className="rounded-2xl border bg-white p-6 shadow-sm transition-colors hover:bg-gray-50">
      <h3 className="text-lg font-semibold">{title}</h3>
      <p className="mt-2 text-sm text-gray-600">{desc}</p>
    </div>
  );
}

function Logo({ className = "h-6 w-6" }: { className?: string }) {
  // Minimalist hexagon + bulb mark (monochrome, fits light/dark backgrounds)
  return (
    <svg viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg" className={className} aria-hidden>
      <path
        d="M32 4 8 18v28l24 14 24-14V18L32 4Z"
        fill="none"
        stroke="currentColor"
        strokeWidth="4"
        strokeLinejoin="round"
      />
      {/* bulb */}
      <circle cx="32" cy="32" r="8" fill="currentColor" />
      <rect x="28.5" y="41" width="7" height="3" rx="1.5" fill="currentColor" />
      <rect x="29.5" y="46" width="5" height="3" rx="1.5" fill="currentColor" />
      {/* rays */}
      <path d="M32 16v6M20 22l4 4M44 22l-4 4" stroke="currentColor" strokeWidth="3" strokeLinecap="round" />
    </svg>
  );
}
