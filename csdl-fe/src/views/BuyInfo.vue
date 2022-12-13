<template>
    <div class="container-in">
        <div class="statistic">
            <h1 class="thongke">Đơn hàng đã xử lý</h1>
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

<style>
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
    margin: 20px;
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
            header: ['Mã hoá đơn', 'Mã đơn', 'Mặt hàng', 'Loại', 'Màu', 'Số lượng', 'Ngày bán', 'Đơn giá', 'Thành tiền']
        }
    },
    computed: {
    },
    async created() {
        await DataService.getBuyInfo(this.$store.state.auth.token).then(
            (res) => {
                this.table = res.map(function (item) {
                    return Object.keys(item).map(function (k) {
                        if(k==='unit_price'){
                            item[k] = item[k].toLocaleString('en-US', {
                            style: 'currency',
                            currency: 'VND',
                            })
                        } else if(k==='total'){
                            item[k] = item[k].toLocaleString('en-US', {
                            style: 'currency',
                            currency: 'VND',
                            })
                        }
                        return item[k]
                    })
                });
            },
        );
    },
}
</script>
