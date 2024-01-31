import { SignOutButton, SignInButton, SignedIn, SignedOut, useUser } from "@clerk/clerk-react"

function App() {
  const { isSignedIn, user, isLoaded } = useUser();

  return (
    <div>
      <SignedOut>
        <SignInButton />
        <p>This content is public. Only signed out users can see this.</p>
      </SignedOut>
      <SignedIn>
        <SignOutButton />
        <p>This content is private. Only signed in users can see this.</p>
        <button onClick={sendRequest}>Send request</button>
      </SignedIn>
    </div>
  )
}

function sendRequest() {
  console.log("sending request ...")
  fetch(
    "https://j5qhov8buk.execute-api.us-east-1.amazonaws.com/dev/test/",
    {
      method: 'POST',
      body: JSON.stringify({ user_id: 'hello' }),
    },
  )
    .then(response => response.json())
    .then(json => console.log(json))
    .catch(error => console.error(error));
}

export default App
