const makePayment = (data) => {
  return fetch(
    "http://localhost:4567/adyen/payments", 
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
      }
    )
    .then((response) => response.json());
}


fetch("http://localhost:4567/adyen/get_origin_key", {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify()
}).then((response) => response.json()).then((response) => {
  return response.originKeys[Object.keys(response.originKeys)[0]]
}).then(originKey => {
    fetch("http://localhost:4567/adyen/payment_methods").then((response) => {
      return response.json()
    }).then(paymentMethodsResponse => {
        // 1. Create an instance of AdyenCheckout
        const checkout = new AdyenCheckout({
            environment: 'test',
            originKey: originKey,
            paymentMethodsResponse
        });

        // 2. Create and mount the Component
        const dropin = checkout
            .create('dropin', {
                // Events
                onSelect: activeComponent => {
                    // updateStateContainer(activeComponent.data); // Demo purposes only
                },
                onChange: state => {
                    // updateStateContainer(state); // Demo purposes only
                },
                onSubmit: (state, component) => {
                    // state.data;
                    // state.isValid;
                    console.log(state);
                    makePayment(state.data).then((data) =>{
                      dropin.handleAction(action);
                    });
                }
            })
            .mount('#dropin-container');
    });
});