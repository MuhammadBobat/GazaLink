import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { StatusBar } from 'expo-status-bar';

import MessageQueueScreen from './src/screens/MessageQueueScreen';
import MessageCreateScreen from './src/screens/MessageCreateScreen';
import DashboardScreen from './src/screens/DashboardScreen';

export type RootStackParamList = {
  MessageQueue: undefined;
  MessageCreate: undefined;
  Dashboard: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();

export default function App() {
  return (
    <NavigationContainer>
      <StatusBar style="light" />
      <Stack.Navigator
        initialRouteName="MessageQueue"
        screenOptions={{
          headerShown: false,
        }}
      >
        <Stack.Screen name="MessageQueue" component={MessageQueueScreen} />
        <Stack.Screen name="MessageCreate" component={MessageCreateScreen} />
        <Stack.Screen name="Dashboard" component={DashboardScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
