import React, { useState } from 'react';

function LoginForm() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loginResult, setLoginResult] = useState('');

  const handleSubmit = async (event) => {
    event.preventDefault();

    const loginData = {
      email: email,
      password: password
    };

    try {
      const response = await fetch('http://192.168.0.101:5111/api/Auth/doLogin', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(loginData)
      });

      const data = await response.json();

      if (data.result === true) {
        localStorage.setItem('refreshToken', data.refreshToken);
        localStorage.setItem('token', data.accessToken);
        localStorage.setItem('isLoggedIn', true);
        setLoginResult('Login successful');
        window.location.href = 'index.html';
        console.log('Done');
      } else {
        localStorage.removeItem('isLoggedIn');
        setLoginResult('Login failed: ' + data.errors[0]);
      }
    } catch (error) {
      console.error('An error occurred:', error);
      setLoginResult('An error occurred while processing your request');
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('refreshToken');
    localStorage.removeItem('isLoggedIn');
    window.location.href = 'signin.html';
  };

  return (
    <div>
      <form id="loginForm" onSubmit={handleSubmit}>
        <input
          type="email"
          id="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="Email"
          required
        />
        <input
          type="password"
          id="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="Password"
          required
        />
        <button type="submit">Login</button>
      </form>
      <div id="resultContainer">{loginResult}</div>
      <button id="logoutButton" onClick={handleLogout}>
        Logout
      </button>
    </div>
  );
}

export default LoginForm;