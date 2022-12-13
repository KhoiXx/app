
<template>
  
  <div class="background"></div>
  <div class="navbar">
    <nav class="nav">
      <div class="nav-el" id="name_project">
        <img src="./assets/logo.png" width="30" class="me-2" alt="" />
        <span>DEMO APP</span>
      </div>
      <div class="nav-el end">
        <a @click="signOut" href="#" v-if="isLoggedIn"><span class="glyphicon glyphicon-log-in"></span></a>
      </div>
    </nav>
  </div>
  <router-view />
</template>

<script>
export default {
  data() {
    return {
      username: "",
      password: "",
    };
  },
  methods: {
    signOut() {
      this.$store.dispatch("auth/logout");
      console.log("Sign Out completed");
      this.$router.push("/");
    },
  },
  computed: {
    isLoggedIn() {
      return this.$store.state.auth.loggedIn;
    }
  }
};
</script>
<style>
/* CUSTOM STYLE */


.background {
  width: 100vw;
  height: 100vh;
  position: absolute;
  background: rgb(250, 250, 250);
}

.navbar {
  z-index: 1;
  background: #327b95;
  position: absolute;
  top: 10px;
  left: 1vw;
  width: 98vw;
  height: 60px;
  border-radius: 10px;
  box-shadow: 6.7px 6.7px 5.3px rgba(0, 0, 0, 0.028),
    22.3px 22.3px 17.9px rgba(0, 0, 0, 0.042),
    100px 100px 80px rgba(0, 0, 0, 0.07);
}

.nav {
  width: 80%;
  min-width: 400px;
  margin: auto;
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
  /* background: #fafafa; */
}
.end {
  width: 85%;
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: flex-end;
  /* font-size: 1.6em; */
}

.nav-el a {
  color: #ffffff;
  text-decoration: none;
  line-height: 100%;
  font-size: 1.6em;
  /* padding: 14px 20px; */
  font-weight: bold;
  font-family: 'Be Vietnam Pro', sans-serif ;
}
#name_project {
  color: #ffffff;
  text-decoration: none;
  line-height: 100%;
  font-size: 1.6em;
  /* padding: 14px 20px; */
  font-weight: bold;
  font-family: 'Be Vietnam Pro', sans-serif ;
}

/* .container {
  width: 400px;
  max-width: 95%;
} */

.input {
  display: flex;
  flex-direction: column;
  margin-bottom: 15px;
}

.input > label {
  text-align: start;
}

.input > input {
  margin-top: 6px;
  height: 38px !important;
}

/* From uiverse.io */
.btn-pers {
  position: relative;
  left: 50%;
  padding: 1em 2.5em;
  font-size: 12px;
  text-transform: uppercase;
  letter-spacing: 2.5px;
  font-weight: 700;
  color: #000;
  background-color: #fff;
  border: none;
  border-radius: 45px;
  box-shadow: 0px 8px 15px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease 0s;
  cursor: pointer;
  outline: none;
  transform: translateX(-50%);
}

.btn-pers:hover {
  background-color: #198754;
  box-shadow: 0px 15px 20px rgba(46, 229, 157, 0.4);
  color: #fff;
  transform: translate(-50%, -7px);
}

.btn-pers:active {
  transform: translate(-50%, -1px);
}

/*  */

.alternative-option {
  text-align: center;
}

.alternative-option > span {
  color: #0d6efd;
  cursor: pointer;
}

#sign_out {
  position: relative;
  left: 50%;
  transform: translateX(-50%);
}
</style>
