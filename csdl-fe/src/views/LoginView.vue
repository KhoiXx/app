<template>
  <div class="container" style="{padding: 3rem 3rem}">
    <form @submit.prevent="login">
      <h2 class="mb-3">Login</h2>
      <div class="input">
        <label for="username">Username</label>
        <input
          class="form-control"
          type="text"
          name="username"
          placeholder="username"
        />
      </div>
      <div class="input">
        <label for="password">Password</label>
        <input
          class="form-control"
          type="password"
          name="password"
          placeholder="password"
        />
      </div>
      <div class="alternative-option mt-4">
        You don't have an account? <span @click="moveToRegister">Register</span>
      </div>
      <button type="submit" class="mt-4 btn-pers" id="login_button">
        Login
      </button>
      <div
        class="alert alert-warning alert-dismissible fade show mt-5 d-none"
        role="alert"
        id="alert_1"
      >
        Lorem ipsum dolor sit amet consectetur, adipisicing elit.
        <button
          type="button"
          class="btn-close"
          data-bs-dismiss="alert"
          aria-label="Close"
        ></button>
      </div>
    </form>
  </div>
</template>
<style>

.container {
  position: absolute;
  top: 50vh;
  left: 50vw;
  transform: translate(-50%, -50%);
  border: 1px solid lightgray;
  /* padding: 4rem 4rem; */
  border-radius: 5px;
  background: #fefefe;
  padding: 4rem 4rem;
  width: 400px;
  max-width: 95%;
}
</style>
<script>
// import { getAuth, signInWithEmailAndPassword } from "firebase/auth";
import AuthService from "@/services/login_service";
import DataService from "@/services/data_service";

export default {
  data() {
    return {
      username: "",
      password: "",
      userName: "",
      order: 0,
      debt: "0",
      groupName: "",
    };
  },
  methods: {
    async login(submitEvent) {
      this.username = submitEvent.target.elements.username.value;
      this.password = submitEvent.target.elements.password.value;
      // this.$router.push("/dashboard");
      await AuthService.login(this.username, this.password, this).then(
        () => {
          this.$router.push("/home")
        },
        (error) => {console.log(error); alert("Cannot login");}
      );
    },
    moveToRegister() {
      this.$router.push("/register");
    },
  },
};
</script>
