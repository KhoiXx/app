import { createRouter, createWebHistory } from "vue-router";
import LoginView from "../views/LoginView.vue";
// import { getAuth } from "firebase/auth";

const routes = [
  {
    path: "/",
    name: "login",
    component: LoginView,
  },
  {
    path: "/register",
    name: "register",
    component: () =>
      import(/* webpackChunkName: "about" */ "../views/RegisterView.vue"),
  },
  {
    path: "/dashboard",
    name: "dashboard",
    component: () =>
      import(/* webpackChunkName: "about" */ "../views/DashboardView.vue"),
      children: [
        {
          path: "/home",
          name: "homepage",
          component: () => import("../views/HomePage.vue"),
        },
        {
          path: "/orderinfo",
          name: "Order Page",
          component: () => import("../views/OrderInfo.vue"),
        },
        {
          path: "/buyinfo",
          name: "Sale Page",
          component: () => import("../views/BuyInfo.vue"),
        },
        {
          path: "/placeorder",
          name: "Place Order Page",
          component: () => import("../views/PlaceOrder.vue"),
        },
        {
          path: "/account",
          name: "Developing Page",
          component: () => import("../views/Account.vue"),
        }
      ],
    meta: {
      authRequired: true,
    },
  },
];

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes,
});

//   if (to.matched.some((record) => record.meta.authRequired)) {
//     if(from.matched.some((x) => x.name === "login")){
//       next();
//     } else {
//       try{
//         var auth = this.$store.state.auth.loggedIn;
//       }catch{
//         router.push("/");
//       }
//       console.log(auth)
//       if (auth) {
//         next();
//       } else {
//         alert("You've must been logged to access this area");
//         router.push("/");
//       }
//     }
//   } else {
//     next();
//   }
// });

export default router;
