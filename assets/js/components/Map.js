import React, { useState, useEffect } from 'react'
import { Map, Marker, Popup, TileLayer } from 'react-leaflet'
import { Socket } from 'phoenix'
import { usePosition } from '../lib/usePosition'
import Geohash from 'latlon-geohash'

const geohashFromPosition = (position) =>
    position ? Geohash.encode(position.lat, position.lng, 5) : ""

export default ({ user }) => {
    const position = usePosition()
    const [channel, setChannel] = useState()
    const [userChannel, setUserChannel] = useState()

    // The Client will open a connection to the socket, when the user logs in  on the map
    // We use Socket constructor provided by Phoenix JS Library, by passing the authentication token as a parameter.

    useEffect(() => {
        const socket = new Socket('/socket', { params: { token: user.token } });
        socket.connect()

        if (!position) {
            return
        }

        // Here we are joining a channel on the given topic by calling the function channel() and join()
        // The function receive() allows us to register a callback for when the client is ready to send and receive on that topic

        // NOTE that we’re giving the computed geohash value as a useEffect dependency, so the effect function will be re-run whenever the geohash changes

        const phxChannel = socket.channel('cell:' + geohashFromPosition(position))
        phxChannel.join().receive('ok', response => {
            console.log('Joined Channel')
            setChannel(phxChannel)
        })

        const phxUserChannel = socket.channel('user:' + user.id)
        phxUserChannel.join.receive('ok', response => {
            console.log('Joined user channel!')
            setUserChannel(phxUserChannel)
        })

        return () => phxChannel.leave()
    }, [
        // we need to pass the geohas in a useEffect dependency
        // so that we can connect to a different channel when the current positions's geohash changes
        geohashFromPosition(position)
    ])

    if (!channel || !userChannel) {
        return (<div>Connecting to Channel.....</div>)
    }

    if (!position) {
        return (<div>Awaiting for Position.....</div>)
    }


    const requestRide = () => channel.push('ride:request', { position: position })

    // We will keep a state of all received ride requests,
    // so we can display a marker on the map for each of them, and provide the UI to accept a request

    const [rideRequests, setRideRequests] = useState([])

    userChannel.on('ride:created', ride =>
        console.log('A Ride has been created'))

    channel.on('ride:requested', rideRequest =>
        setRideRequests(rideRequests.concat([rideRequest]))
    )

    let acceptRideRequest = (request_id) => channel.push('ride:accept_request', {
        request_id
    })

    return (
        <div>
            Logged in as {user.type}
            {user.type == 'rider' && (<div>
                <button onClick={requestRide}>Request a Ride</button>
            </div>)}
            <MapContainer
                centre={position} zoom={15} scrollWheelZoom={false}>
                <TileLayer
                    url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                    attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                />

                <Marker position={position}>
                </Marker>
            </MapContainer>
        </div>
    )
}