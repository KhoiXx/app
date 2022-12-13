export const info = {
    namespaced: true,
    state: {
        customer_id: null,
        customer_group: null,
        debt: 0,
        user_name: "",
        order_count: 0,
    },
    actions: {
        saveInfo({commit}, info){
            commit("saveInfo", info)
        }
    },
    mutations:{
        saveInfo(state, info){
            state.user_name = info[0]
            state.debt = info[1]
            state.order_count = info[2]
            state.customer_group = info[3]
        }
    }
}