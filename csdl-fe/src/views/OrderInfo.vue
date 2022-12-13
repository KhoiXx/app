<template>
    <div class="container-in">
        <div class="statistic">
            <h1 class="thongke">Đơn hàng đã đặt</h1>
            <!-- <form action="/action_page.php">
                <select  class="form-select" name="cars" id="cars">
                    <option v-for="item in elements['order_id']" :key="item">{{item}}</option>
                </select>
                <select class="form-select" name="cars" id="cars">
                    <option value="volvo">Volvo</option>
                    <option value="saab">Saab</option>
                    <option value="opel">Opel</option>
                    <option value="audi">Audi</option>
                </select>
                <button><span class="glyphicon glyphicon-search"></span></button>
            </form> -->
            <div class="stat-items">
                <table class="table">
                    <thead>
                        <tr>
                            <th v-for="item in header" :key="item" scope="col">{{ item }}</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- <tr>
                            <th v-for="item in table[header[0]]" scope="row">{{item}}</th>
                        </tr> -->
                        <tr v-for="row in table" :key="row">
                            <th v-for="cell in row" :key="cell" scope="row">{{ cell }}</th>
                        </tr>
                    </tbody>
                </table>

            </div>
        </div>
    </div>
</template>

<style scoped>
button {
    border: none;
    border-radius: 15px;
    height: 100%;
    background-color: transparent;
    font-size: 1.7em;
}

form {
    display: flex;
    flex-direction: row;
    align-items: center;

    margin: 20px 50px 0px 50px
}

form>label {
    font-size: 1.7em;
    margin-right: 30px;
}

form>select.form-select {
    line-height: 1.9em;
    font-size: 1.7em;
    margin-right: 20px;
}

.table>tbody>tr>th {
    font-weight: 300 !important;
    text-align: end;
}

.table>thead>tr>th {
    text-align: center;
}

.table {
    font-size: 15px;
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

.stat-items {
    display: flex;
    flex-direction: row;
    width: 95%;
    margin-left: 20px;
    margin-right: 20px;
    /* margin-top: 45px; */
    align-items: center;
    justify-content: center;
    padding: 12px 20px 20px 20px;
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
    background-color: rgb(255, 255, 255);
    border-radius: 7px;
    box-shadow: 0 0px 3px 0 rgb(223 223 223 / 20%), 0 2px 12px 0 rgb(55 55 55 / 19%);
}
</style>

<script>
import DataService from "@/services/data_service";
export default {
    data() {
        return {
            table: [],
            elements: {},
            header: ['Mã đơn', 'Ngày tạo', 'Mặt hàng', 'Loại', 'Màu', 'Số lượng', 'Trạng thái', 'Ngày cập nhật trạng thái', 'Đã hoàn thành'],
            orderIdFilter: []
        }
    },
    computed: {
    },
    async created() {
        await DataService.getOrderInfo(this.$store.state.auth.token).then(
            (res) => {
                let k = {};
                Object.keys(res[0]).forEach(function (key, i) {
                    k[key] = res.map(function (item) { return item[key] })
                });
                Object.keys(k).forEach(function (key, i) {
                    k[key] = [... new Set(k[key])];
                });
                this.table = res.map(function (item) {
                    return Object.keys(item).map(function (k) {
                        if (k === 'finished') {
                            if (item[k]) {
                                item[k] = "x"
                            } else {
                                item[k] = ""
                            }
                        }
                        return item[k]
                    })
                });
            },
            (err) => {
                console.log(err)
            }
        );
    },
    mounted() {
        if (!this.$store.state.auth.loggedIn) {
            this.$router.push("/");
        }
    },
}
</script>
