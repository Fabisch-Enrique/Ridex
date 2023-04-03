import React, { useState } from "react";

export default ({ onLogin }) => {
    const [phone, setPhone] = useState('')

    const onChannge = (event) =>
        setPhone(event.target.value)

    const login = userType => () =>
        fetch('/api/authenticate', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                phone: phone,
                type: userType
            })
        }).then(res => res.join())
            .then(user => onLogin(user))
    
    return(<div>
        <p>Welcome to Ridex! Please Check in using your phone number</p>
        <input
            type="test"
            placeholder="Phone Number"
            value={phone}
            onChange={onChange} />

        <button onClick={login('driver')}>Login as Driver</button>
        <button onClick={login('rider')}>Login as Rider</button>
    </div>)
}