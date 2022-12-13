import axios from "axios";
import AuthService from "@/services/login_service";

class DataService {
    async getDebt(token) {
        return await AuthService.getService(token, "get_debt")
    }
    async getOrderCount(token) {
        return await AuthService.getService(token, "order_count")
    }
    async getCustomerGroup(token) {
        return await AuthService.getService(token, "customer/group")
    }
    async getOrderInfo(token) {
        return await AuthService.getService(token, "customer/order_info")
    }
    async getBuyInfo(token) {
        return await AuthService.getService(token, "customer/buy_info")
    }
    async getGoodsInfo(token) {
        return await AuthService.getService(token, "goods")
    }
    async postOrder(token, order) {
        return await axios.post("place_order", order, {
        headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`
        }
        }).then(
            (response) => response.data,
            (reject) => {console.log(reject)}
        );
    }
}
export default new DataService();