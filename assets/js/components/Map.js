import React, { useState, useEffect } from 'react'
import { Map, Marker, TileLayer } from 'react-leaflet'
import { usePosition } from '../lib/usePosition'

export default ({ user }) => {
    const position = usePosition()

    if (!position) {
        return (<div>Awaiting for Position.....</div>)
    }

    return (
        <div>
            Logged in as {user.type}
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