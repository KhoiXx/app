<template>
  <div class="container-new">
    <Menu :items="getMenuList"></Menu>
    <div class="wrap">
      <router-view></router-view>
    </div>
  </div>
</template>

<style scoped>
.container-new {
  width: 100vw;;
  height: 100vh;
  left: 0;
  bottom: 0;
  position: absolute;
  
  /* display: flex;
  flex-direction: row;
  align-items: flex-start;
  justify-content: space-between; */
}
.wrap {
  width: calc(100% - 260px);
  height: calc(100% - 70px);
  left: 0;
  bottom: 0;
  position: absolute;
  padding: 4rem;
}
</style>

<script>
// eslint-disable-next-line
import Menu from "@/views/Menu.vue"
// import { getAuth } from "firebase/auth";
// const auth = getAuth();

export default {
  components: {
    Menu,
  },
  data() {
    return {
      username: this.$store.state.auth.user,
      menuList: [],
    };
  },
  computed:{
    getMenuList(){
      switch(this.$store.state.auth.permission){
        case 0:
          return ['Trang chủ', 'Thông tin giao nhận', 'Nhân viên', 'Tài khoản', 'Cài đặt']
        case 1:
          return ['Trang chủ', 'Đơn đã đặt', 'Đơn đã mua', 'Đặt hàng', 'Tài khoản', 'Cài đặt']
        case 2:
          return ['Trang chủ', 'Quản lí đơn hàng', 'Quản lí khách hàng', 'Quản lí nhân viên', 'Tạo tài khoản', 'Tài khoản', 'Cài đặt']
        default:
          return ['Trang chủ', 'Cài đặt']
      }
    }
  },
  methods: {
    signOut() {
      this.$store.dispatch("auth/logout");
      console.log("Sign Out completed");
      this.$router.push("/");
    },
  },
  mounted() {
    if (!this.$store.state.auth.loggedIn) {
      this.$router.push("/");
    }
  },
  created(){
    // this.$router.push("/dashboard/home");
    console.log(this.$store.state.auth.loggedIn);
  }
};
</script>
