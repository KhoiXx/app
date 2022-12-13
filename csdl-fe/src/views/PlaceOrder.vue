<template>
    <div class="container-in">
        <div class="statistic">
            <h1 class="thongke">Đặt hàng</h1>
            <form>
                <!-- <select  class="form-select" name="cars" id="cars">
                <option v-for="item in elements['order_id']" :key="item">{{item}}</option>
            </select> -->
                <div class="select-list">
                    <div class="select-row">
                        <label for="goods_id">Chọn mã sản phẩm:</label>
                        <select class="form-select" name="goods_id" id="goods_id" v-model="masanpham">
                            <option v-for="item in info_dict['Mã sản phẩm']" :key="item">{{ item }}</option>
                        </select>
                    </div>
                    <div class="select-row">
                        <label for="goods_name">Tên sản phẩm:</label>
                        <input id="goods_name" type="text" disabled placeholder="" v-model="name" />
                    </div>
                    <div class="select-row">
                        <label for="goods_categories">Phân loại sản phẩm:</label>
                        <input id="goods_categories" type="text" disabled placeholder="" v-model="loai" />
                    </div>
                    <div class="select-row">
                        <label for="goods_color">Màu sắc:</label>
                        <input id="goods_color" type="text" disabled placeholder="" v-model="mausac" />
                    </div>
                    <div class="select-row">
                        <label for="amount">Số lượng đặt hàng:</label>
                        <input id="amount" type="number" v-model="amount" placeholder="" />
                    </div>
                    <div class="select-row" style="margin-top: 10px;justify-self: flex-end!important;">
                        <div style="width:85%;"></div>
                        <button @click.prevent="submitClicked()"> Submit <span
                                class="glyphicon glyphicon-share"></span></button>
                    </div>
                </div>
                <!-- <button><span class="glyphicon glyphicon-share"></span></button> -->
            </form>
        </div>
    </div>
</template>

<style scoped>
button {
    border: none;
    font-size: 1.9em;
    padding: 10px;
    border-radius: 8px;
    background-color: green;
    color: #fafafa;
}

.select-list {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    justify-content: space-evenly;
    width: 100%;
}

.select-row {
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: flex-start;
    height: 50px;
    width: 100%;
}

form {
    display: flex;
    flex-direction: row;
    align-items: center;
    padding-bottom: 30px;

    margin: 20px 50px 0px 50px;
}

form>.select-list>.select-row>label {
    font-size: 1.5em;
    margin-right: 30px;
    width: 25%;
    /* line-height: 50px; */
}

form>.select-list>.select-row>select.form-select {
    line-height: 1.9em;
    font-size: 1.4em;
    margin-right: 20px;
    width: 80%;
}

form>.select-list>.select-row>input {
    line-height: 1.9em;
    font-size: 1.4em;
    margin-right: 20px;
    width: 80%;
}

.container-in {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
}

.thongke {
    font-size: 25px;
    font-weight: 500;
    /* margin-top: -30px!important; */
    color: green;
    margin-left: 30px;
    margin-top: -15px;
    width: fit-content;
    background-color: #fafafa;
    /* background-color: black; */
    /* left: 0; */
}

.statistic {
    /* display: flex;
    position: relative; */
    width: 90%;
    /* height: 80%; */
    /* border: 1px solid black; */
    margin: auto;
    margin-top: 20px;
    margin-bottom: 30px;
    /* padding-top: 50px; */
    /* padding-bottom: 40px;s */
    align-self: center;
    /* background-color: rgb(255, 255, 255);
    border-radius: 7px;
    box-shadow: 0 0px 3px 0 rgb(223 223 223 / 20%), 0 2px 12px 0 rgb(55 55 55 / 19%); */
}
</style>

<script>
import DataService from "@/services/data_service";
export default {
    data() {
        return {
            goods_menu: ['Mã sản phẩm', 'Tên sản phẩm', 'Phân loại', 'Màu sắc'],
            info_dict: {},
            masanpham: null,
            name: "",
            loai: "",
            mausac: "",
            amount: 0,
        }
    },
    async created() {
        await DataService.getGoodsInfo(this.$store.state.auth.token).then(
            (res) => {
                let k = {};
                let temp_goods_menu = this.goods_menu
                Object.keys(res[0]).forEach(function (key, i) {
                    k[temp_goods_menu[i]] = res.map(function (item) { return item[key] })
                });
                this.info_dict = k;
            });
    },
    methods: {
        async submitClicked() {
            let data = {
                "goods_id": parseInt(this.masanpham),
                "amount": parseInt(this.amount),
            }
            if (!this.amount) {
                alert("Please input a valid amount");
                return;
            }
            // alert(data);
            await DataService.postOrder(this.$store.state.auth.token, data).then(
                (res) => {
                    console.log(res);
                    if (res) {
                        alert("Đặt hàng thành công")
                        this.masanpham = null;
                        this.amount = 0;
                        this.name = "";
                        this.mausac = "";
                    } else {
                        alert("Đặt hàng thất bại")
                    }
                },
                () => {
                    console.log("Error");
                }
            );
        }
    },
    watch: {
        masanpham(val) {
            // ['Mã sản phẩm','Tên sản phẩm','Phân loại','Màu sắc']
            let index = this.info_dict['Mã sản phẩm'].findIndex(x => x === parseInt(val));
            this.name = this.info_dict['Tên sản phẩm'][index];
            this.loai = this.info_dict['Phân loại'][index];
            this.mausac = this.info_dict['Màu sắc'][index];
        }
    },
    mounted() {
        if (!this.$store.state.auth.loggedIn) {
            this.$router.push("/");
        }
    },
}
</script>