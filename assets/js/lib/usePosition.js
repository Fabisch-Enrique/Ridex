import { useState, useEffect } from "react";

// custom hook usePosition to retrieve user location from  the Map component

export const usePosition = () => {
    const [position, setPosition] = useState()

    useEffect(() => {
    const watcher = navigator.geolocation.getCurrentPosition(({ coords }) => setPosition({
        lat: coords.latitude,
        lng: coords.longitude,
    }))

    return () => navigator.geolocation.clearWatch(watcher)
    }, [])

    return position
}