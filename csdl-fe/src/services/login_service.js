import axios from "axios";
// const API_URL = "http://192.168.1.210/api/";
class AuthService {
  async login(Username, Password, that) {
    let data = {
      "username": Username,
      "password": Password,
    };
    let response_data = await axios.post("token", data, {
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json"
      }
    }).then(
      (response) => response.data,
      (reject) => {
        console.log(reject.response.status)
      }
    );
    
    let user = await this.getUser(response_data.access_token);
    let login_info = {
      "status": true,
      "username": Username,
      "token": response_data.access_token,
      "permission": user.permission,
    };
    return that.$store.dispatch("auth/login",login_info);
  
  }
  async getUser(token) {
    try {
      if (token === null) {
        return "You are not logged in"
      }
      return axios.get("users/me", {
        headers: { Authorization: `Bearer ${token}` },
      }).then(
        (response) => response.data,
        (error) => { console.log(error) });
    } catch (error) {
      console.log(error);
    }
  }
  async getService(token, endpoint){
    try {
      if (token === null) {
        return "You are not logged in"
      }
      return await axios.get(endpoint, {
        headers: { Authorization: `Bearer ${token}` },
      }).then(
        (response) => response.data,
        (error) => { console.log(error)});
    } catch (error) {
      console.log(error);
    }
  }
  async getUserName(token){
    return await this.getService(token, "users/name")
  }
}
export default new AuthService();
