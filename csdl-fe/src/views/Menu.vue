<template>
    <div class="side-nav">
        <div class="nav-list topBotomBordersIn">
            <a v-for="item in items" :key="item"  @click.prevent="route(item)">
                {{ item }}
                <!-- <router-link v-bind:to="getLink(item)"></router-link> -->
            </a>
        </div>
    </div>
</template>

<script>
export default {
    props: ["items"],
    data() {
        return {

        };
    },
    methods: {
        getLink(item) {
            switch (item) {
                case 'Trang chủ':
                    return "/home"
                case 'Đơn đã đặt':
                    return "/orderinfo"
                case 'Đơn đã mua':
                    return "/buyinfo"
                case 'Đặt hàng':
                    return "/placeorder"
                default:
                    return "/account"
            }
        },
        route(item){
            this.$router.push(this.getLink(item));
        }
    },
};
</script>

<style scoped>
.side-nav {
    display: flex;
    flex-direction: column;
    position: absolute;
    bottom: 0px;
    right: 0;
    height: 100%;
    width: 260px;
    background-color: #e2e8f0;
    padding-top: 100px;
}

.side-nav ul {
    padding: 0px 15px;
    width: 100%;
}

.nav-list {
    margin-left: 20px;
    padding: 0em 0em;
    text-align: left;
    display: flex;
    flex-direction: column;
    align-items: flex-start;
}

.nav-list a {
    /* color: #e2e8f0; */
    font-size: 1.6em;
    margin: 0px 10px;
    padding: 10px 10px;
    position: relative;
    cursor: pointer;
}

/* Top and Bottom borders come in */
.topBotomBordersIn a:before,
div.topBotomBordersIn a:after {
    position: absolute;
    left: 0px;
    width: 100%;
    height: 2px;
    background: #FFF;
    content: "";
    opacity: 0;
    transition: all 0.3s;
}

.topBotomBordersIn a:before {
    top: 0px;
    transform: translateY(-10px);
}

.topBotomBordersIn a:after {
    bottom: 0px;
    transform: translateY(10px);
}

.topBotomBordersIn a:hover:before,
.topBotomBordersIn a:hover:after {
    opacity: 1;
    transform: translateY(0px);
}
</style>