import React from "react";
import { Route, Link, Redirect, Switch } from "react-router-dom";

import "../styles/navigation.css";

const AuthService = {
  isAuthenticated: true,
  authenticate(cb) {
    this.isAuthenticated = true;
    setTimeout(cb, 100);
  },
  logout(cb) {
    this.isAuthenticated = false;
    setTimeout(cb, 100);
  }
};

const SecretRoute = ({ component: Component, ...rest }) => (
  <Route
    {...rest}
    render={props =>
      AuthService.isAuthenticated === true ? (
        <Component {...props} />
      ) : (
        <Redirect to="/login" />
      )
    }
  />
);

const CustomLink = ({ children, to, exact }) => (
  <Route
    path={to}
    exact={exact}
    children={() => <Link to={to}>{children}</Link>}
  />
);

// export function addNavBackground() {
//   const elems = document.querySelector(".nav-header");
//   elems.classList.add("nav-header-background");
// }

// export function removeNavBackground() {
//   const elems = document.querySelector(".nav-header");
//   elems.classList.remove("nav-header-background");
// }

const SignIn = () => (
  <>
    <i className="fa fa-sign-in-alt site-nav--icon" /> Log In
  </>
);

const SignOut = () => (
  <>
    <i className="fa fa-sign-out-alt site-nav--icon" /> Log Out
  </>
);

export const Routes = (
  home,
  dashboard,
  detail,
  purchase,
  loginsignup,
  account,
  pricing
) => (
  <>
    <div className="body-container">
      <Switch>
        <Route path="/" exact component={home} />
        <Route path="/home" component={home} />

        <SecretRoute path="/dashboard/" component={dashboard} />

        <SecretRoute path="/detail/" exact component={detail} />
        <SecretRoute path="/detail/:county/:account/" component={detail} />

        <SecretRoute path="/purchase/" exact component={purchase} />
        <SecretRoute path="/purchase/:params" exact component={purchase} />

        <SecretRoute path="/account" component={account} />

        <Route path="/pricing" component={pricing} />

        <Route path="/logout" component={loginsignup} />
        <Route path="/login" component={loginsignup} />
        <Route path="/authentication" component={loginsignup} />

        <Route render={() => <div> Sorry, this page does not exist. </div>} />
      </Switch>
    </div>
  </>
);

const loggedInNav = (state, loginHandler) => (
  <header className="nav-header">
    <div className="nav-container">
      <Link to="/">
        <h1 className="logo">
          Valuation<span>:</span>
        </h1>
      </Link>

      <nav className="site-nav">
        <ul>
          <li>
            <CustomLink to="/dashboard/">
              <i className="fa fa-info site-nav--icon" />
              Dashboard
            </CustomLink>
          </li>
          <li>
            <CustomLink to="/account/">
              <i className="fa fa-info site-nav--icon" />
              Account
            </CustomLink>
          </li>
          <li>
            <span onClick={loginHandler}>
              <CustomLink to="/authentication/">
                {state.loggedIn ? SignOut() : SignIn()}
              </CustomLink>
            </span>
          </li>
        </ul>
      </nav>

      <div className="menu-toggle">
        <div className="hamburger" />
      </div>
    </div>
  </header>
);

const loggedOutNav = (state, loginHandler) => (
  <header className="nav-header">
    <div className="nav-container">
      <Link to="/">
        <h1 className="logo">
          Valuation<span>:</span>
        </h1>
      </Link>

      <nav className="site-nav">
        <ul>
          <li>
            <CustomLink to="/" exact>
              <i className="fa fa-home site-nav--icon" />
              Home
            </CustomLink>
          </li>
          <li>
            <CustomLink to="/pricing/">
              <i className="fa fa-dollar-sign site-nav--icon" />
              Pricing
            </CustomLink>
          </li>

          <li>
            <span onClick={loginHandler}>
              <CustomLink to="/authentication/">
                {state.loggedIn ? SignOut() : SignIn()}
              </CustomLink>
            </span>
          </li>
        </ul>
      </nav>

      <div className="menu-toggle">
        <div className="hamburger" />
      </div>
    </div>
  </header>
);

export function Navbar(state, loginHandler) {
  return (
    <>
      {state.loggedIn
        ? loggedInNav(state, loginHandler)
        : loggedOutNav(state, loginHandler)}
    </>
  );
}
