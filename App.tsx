import React, {useState, useEffect} from 'react';
import {
  View,
  Text,
  Button,
  StyleSheet,
  Platform,
  ToastAndroid,
  NativeModules,
} from 'react-native';
import SharedGroupPreferences from 'react-native-shared-group-preferences';
import AsyncStorage from '@react-native-async-storage/async-storage';
import PushNotification from 'react-native-push-notification';
import PushNotificationIOS from '@react-native-community/push-notification-ios';

const group = 'group.drinkme';

const SharedStorage = NativeModules.SharedStorage;

const App = () => {
  const [glasses, setGlasses] = useState<number>(0);
  const widgetData = {
    glasses,
  };

  useEffect(() => {
    loadGlasses();
    configurePushNotifications();
    scheduleNotification();
  }, []);

  const loadGlasses = async () => {
    try {
      const value = await AsyncStorage.getItem('glasses');
      if (value !== null) {
        setGlasses(parseInt(value));
      }
    } catch (error) {
      console.error(error);
    }
  };

  const saveGlasses = async (value: number) => {
    try {
      if (Platform.OS === 'ios') {
        await SharedGroupPreferences.setItem('drinked', widgetData, group);
      } else {
        SharedStorage.set(JSON.stringify({text: value}));
        ToastAndroid.show('Change value successfully!', ToastAndroid.SHORT);
      }
      await AsyncStorage.setItem('glasses', value.toString());
    } catch (error) {
      console.error(error);
    }
  };

  const addGlass = () => {
    const newGlasses = glasses + 1;
    setGlasses(newGlasses);
    saveGlasses(newGlasses);
  };

  const configurePushNotifications = () => {
    PushNotification.configure({
      onRegister: function (token: any) {
        console.log('TOKEN:', token);
      },
      onNotification: function (notification: any) {
        console.log('NOTIFICATION:', notification);
        notification.finish(PushNotificationIOS.FetchResult.NoData);
      },
      permissions: {
        alert: true,
        badge: true,
        sound: true,
      },
      popInitialNotification: true,
      requestPermissions: true,
    });
  };

  const scheduleNotification = () => {
    PushNotification.localNotificationSchedule({
      message: "N'oubliez pas de boire de l'eau!",
      date: new Date(Date.now() + 3600 * 1000),
      repeatType: 'hour',
    });
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Rappels d'Hydratation</Text>
      <Text style={styles.text}>Verres d'eau bus aujourd'hui : {glasses}</Text>
      <Button title="Ajouter un verre d'eau" onPress={addGlass} />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f0f8ff',
  },
  title: {
    fontSize: 24,
    marginBottom: 20,
  },
  text: {
    fontSize: 18,
    marginBottom: 20,
  },
});

export default App;
