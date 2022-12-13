<template>
    <div class="container-in">
        <h2>Chào {{ this.timeMsg }} {{ this.userName }},</h2>
        <div class="statistic">
            <h1 class="thongke">Thống kê của bạn</h1>
            <div class="stat-items">
                <div class="report-box zoom-in">
                    <div class="box p-5">
                        <div class="flex">
                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
                                fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                stroke-linejoin="round" icon-name="shopping-cart" data-lucide="shopping-cart"
                                class="lucide lucide-shopping-cart report-box__icon text-primary">
                                <circle cx="9" cy="21" r="1"></circle>
                                <circle cx="20" cy="21" r="1"></circle>
                                <path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"></path>
                            </svg>
                            <div class="ml-auto">
                                <div class="report-box__indicator bg-success tooltip cursor-pointer"> 33% <svg
                                        xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
                                        fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                        stroke-linejoin="round" icon-name="chevron-up" data-lucide="chevron-up"
                                        class="lucide lucide-chevron-up w-4 h-4 ml-0.5">
                                        <polyline points="18 15 12 9 6 15"></polyline>
                                    </svg> </div>
                            </div>
                        </div>
                        <span class="item-number">{{this.order}}</span>
                        <div class="item-name">Đơn hàng</div>
                    </div>
                </div>
                <div class="report-box zoom-in">
                    <div class="box p-5">
                        <div class="flex">
                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
                                fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                stroke-linejoin="round" icon-name="dollar-sign" data-lucide="dollar-sign"
                                class="lucide lucide-dollar-sign">
                                <line x1="12" y1="1" x2="12" y2="23"></line>
                                <path d="M17 5H9.5a3.5 3.5 0 000 7h5a3.5 3.5 0 010 7H6"></path>
                            </svg>
                            <div class="ml-auto">
                                <div class="report-box__indicator bg-success tooltip cursor-pointer"> 33% <svg
                                        xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
                                        fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                        stroke-linejoin="round" icon-name="chevron-up" data-lucide="chevron-up"
                                        class="lucide lucide-chevron-up w-4 h-4 ml-0.5">
                                        <polyline points="18 15 12 9 6 15"></polyline>
                                    </svg> </div>
                            </div>
                        </div>
                        <span class="item-number">{{this.debt}}</span>
                        <div class="item-name">Công nợ</div>
                    </div>
                </div>
                <div class="report-box zoom-in">
                    <div class="box p-5">
                        <div class="flex">
                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
                                fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                stroke-linejoin="round" icon-name="user" data-lucide="user"
                                class="lucide lucide-user report-box__icon text-success">
                                <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"></path>
                                <circle cx="12" cy="7" r="4"></circle>
                            </svg>
                            <div class="ml-auto">
                                <div class="report-box__indicator bg-success tooltip cursor-pointer"> 33% <svg
                                        xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
                                        fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                        stroke-linejoin="round" icon-name="chevron-up" data-lucide="chevron-up"
                                        class="lucide lucide-chevron-up w-4 h-4 ml-0.5">
                                        <polyline points="18 15 12 9 6 15"></polyline>
                                    </svg> </div>
                            </div>
                        </div>
                        <span class="item-number">{{this.groupName}}</span>
                        <div class="item-name">Nhóm khách hàng</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<style scoped>
.container-in {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
}

.statistic {
    /* display: flex;
    position: relative; */
    /* max-width:70%; */
    /* height: 80%; */
    /* border: 1px solid black; */
    width: max-content;
    margin: auto;
    margin-top: 50px;
    margin-bottom: 50px;
    /* padding-top: 50px; */
    padding-bottom: 40px;
    align-self: center;
    background-color: rgb(255, 255, 255);
    border-radius: 7px;
    box-shadow: 0 0px 3px 0 rgb(223 223 223 / 20%), 0 2px 12px 0 rgb(55 55 55 / 19%);
}

.statistic>span {}

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
    margin-top: 45px;
    align-items: center;
    justify-content: space-evenly;
}

.item-number {
    font-size: 20px;
    font-weight: 600;
}

.item-name {
    margin-top: 8px;
    font-size: 15px;
    color: rgba(0, 0, 0, 0.571);
}

/* span{
    background: white;
    color: #D70000;
    font-family: 'Be Vietnam Pro', sans-serif;
    font-weight: bolder;
    font-size: 32px;
    border-radius: 10px;
} */
@-webkit-keyframes type-animation {
    50% {
        opacity: 1;
    }
}

@keyframes type-animation {
    50% {
        opacity: 1;
    }
}

.zoom-in {
    transform: translate(var(--tw-translate-x), var(--tw-translate-y)) rotate(var(--tw-rotate)) skewX(var(--tw-skew-x)) skewY(var(--tw-skew-y)) scaleX(var(--tw-scale-x)) scaleY(var(--tw-scale-y));
    cursor: pointer;
    transition-property: color, background-color, border-color, fill, stroke, opacity, box-shadow, transform, filter, -webkit-text-decoration-color, -webkit-backdrop-filter;
    transition-property: color, background-color, border-color, text-decoration-color, fill, stroke, opacity, box-shadow, transform, filter, backdrop-filter;
    transition-property: color, background-color, border-color, text-decoration-color, fill, stroke, opacity, box-shadow, transform, filter, backdrop-filter, -webkit-text-decoration-color, -webkit-backdrop-filter;
    transition-duration: 300ms;
    transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
}

.zoom-in:hover {
    --tw-scale-x: 1.05;
    --tw-scale-y: 1.05;
    transform: translate(var(--tw-translate-x), var(--tw-translate-y)) rotate(var(--tw-rotate)) skewX(var(--tw-skew-x)) skewY(var(--tw-skew-y)) scaleX(var(--tw-scale-x)) scaleY(var(--tw-scale-y));
    --tw-shadow: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1);
    --tw-shadow-colored: 0 20px 25px -5px var(--tw-shadow-color), 0 8px 10px -6px var(--tw-shadow-color);
    box-shadow: var(--tw-ring-offset-shadow, 0 0 #0000), var(--tw-ring-shadow, 0 0 #0000), var(--tw-shadow);
}

.report-box {
    position: relative;
}

.box {
    box-shadow: 0px 3px 20px #0000000b;
    position: relative;
    border-radius: 0.375rem;
    border-color: transparent;
    --tw-bg-opacity: 1;
    background-color: #eeeeee;
    min-width: 180px;
    margin: 0 15px;
}

.dark .box {
    border-color: transparent;
    --tw-bg-opacity: 1;
    background-color: rgb(var(--color-darkmode-600) / var(--tw-bg-opacity));
}

.report-box:before {
    content: "";
    width: 90%;
    box-shadow: 0px 3px 20px #0000000b;
    position: absolute;
    left: 0px;
    right: 0px;
    margin-left: auto;
    margin-right: auto;
    margin-top: 0.75rem;
    height: 100%;
    border-radius: 0.375rem;
    --tw-bg-opacity: 1;
    background-color: #e7e7e7a7;
}

.dark .report-box:before {
    background-color: rgb(var(--color-darkmode-400) / 0.7);
}

.report-box .report-box__icon {
    width: 28px;
    height: 28px;
}

.report-box .report-box__indicator {
    padding-top: 3px;
    padding-bottom: 3px;
    display: flex;
    align-items: flex-end;
    border-radius: 9999px;
    padding-left: 0.5rem;
    padding-right: 0.25rem;
    font-size: 0.75rem;
    line-height: 1rem;
    font-weight: 500;
    --tw-text-opacity: 1;
    color: #dedede;
}
</style>

<script>
import AuthService from "@/services/login_service";
import DataService from "@/services/data_service";
export default {
    data() {
        return {
            timeMsg: "",
            userName: "",
            order: 0,
            debt: "0",
            groupName: "",
        }
    },
    async created() {
        var objDate = new Date();
        var hours = objDate.getHours();
        if (hours > 4 && hours <= 11) {
            this.timeMsg = "buổi sáng";
        } else if (hours > 11 && hours <= 13) {
            this.timeMsg = "buổi trưa";
        } else if (hours > 13 && hours <= 18) {
            this.timeMsg = "buổi chiều";
        } else {
            this.timeMsg = "buổi tối";
        }
        console.log("adadsf",this.$store.state.info.user_name)
        if(this.$store.state.info.user_name === ""){
            await AuthService.getUserName(this.$store.state.auth.token).then(
                (res) => { this.userName = res },
            );
            await DataService.getDebt(this.$store.state.auth.token).then(
                (res) => { this.debt = res },
            );
            await DataService.getOrderCount(this.$store.state.auth.token).then(
                (res) => { this.order = res },
            );
            await DataService.getCustomerGroup(this.$store.state.auth.token).then(
                (res) => { this.groupName = res },
            );
            this.$store.dispatch("info/saveInfo", [this.userName, this.debt, this.order, this.groupName])
        } else {
            this.userName = this.$store.state.info.user_name;
            this.debt = this.$store.state.info.debt;
            this.order = this.$store.state.info.order_count;
            this.groupName = this.$store.state.info.customer_group;
        }
    },
    mounted() {
    if (!this.$store.state.auth.loggedIn) {
      this.$router.push("/");
    }
  }
}
</script>