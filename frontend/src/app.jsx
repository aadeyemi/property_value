import React, { Component } from "react";
import { withRouter } from "react-router-dom";
import { Navbar, Routes } from "./views/navigation_bar";
import HomeView from "./views/view_home";
import DashboardView from "./views/view_dashboard";
import DetailView from "./views/view_detail";
import PurchaseView from "./views/view_purchase";
import LoginSignupView from "./views/view_login_signup";
import AccountView from "./views/view_account";
import PricingView from "./views/view_pricing";

import { testApi } from "./api_test";

class App extends Component {
  state = {
    loggedIn: false,
    activeTab: ""
  };

  loginHandler = () => {
    const status = this.state.loggedIn;
    this.setState({ loggedIn: !status });
  };

  componentDidMount() {
    const menu_toggles = document.getElementsByClassName("menu-toggle");
    const menu_toggle = menu_toggles[0];

    menu_toggle.addEventListener("click", function() {
      const site_navs = document.querySelector(".site-nav");
      site_navs.classList.toggle("site-nav--open");
      document.querySelector(".menu-toggle").classList.toggle("open");
    });
  }

  render() {
    testApi();
    return (
      <React.Fragment>
        {Navbar(this.state, this.loginHandler)}
        {Routes(
          withRouter(HomeView),
          withRouter(DashboardView),
          withRouter(DetailView),
          withRouter(PurchaseView),
          withRouter(LoginSignupView),
          withRouter(AccountView),
          withRouter(PricingView)
        )}
      </React.Fragment>
    );
  }
}
export default App;
