<template>
    <div class="container-in">
        <h1>Developing</h1>
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

.container-in>h1 {
    font-style: italic;
    color: grey;
    text-align: center;
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
export default {
    data() {
        return {        }
    },
    computed: {
    },
    async created() {
    },
}
</script>
