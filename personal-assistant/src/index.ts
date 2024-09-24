import { serve } from "@hono/node-server";
import { generateText, tool } from "ai";
import dotenv from "dotenv";
import { Hono } from "hono";
import { readFileSync } from "node:fs";
import { createOllama } from "ollama-ai-provider";
import { z } from "zod";

dotenv.config();
let app = new Hono();

app.get("/", async (c) => {
  let lattitude = process.env.LATTITUDE;
  let longitude = process.env.LONGITUDE;
  let work = process.env.WORK_LAT_LONG;
  let today = new Date().toISOString();

  let systemPrompt =
    readFileSync("./prompts/system-prompt.xml", "utf8") +
    `today's date is ${today}` +
    `My home's lattitude is: ${lattitude}` +
    `My home's longtitude is: ${longitude}` +
    `My work location is: ${work}` +
    `Use the <exampleResponse> to format your response`;

  let ollama = createOllama({
    baseURL: "http://localhost:11434/api",
  });
  let result = await generateText({
    model: ollama("llama3.1"),
    prompt: systemPrompt,
    maxSteps: 6,
    tools: {
      weather: tool({
        description: "Get today's weather",
        parameters: z.object({
          lattitude: z.number(),
          longitude: z.number(),
        }),
        execute: async () => {
          let weather = await fetch(
            `https://api.open-meteo.com/v1/forecast?latitude=${lattitude}&longitude=${longitude}&current=temperature_2m,wind_speed_10m&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m`
          );
          let weatherData = await weather.json();
          return weatherData;
        },
      }),
      prayerTimes: tool({
        description: "Get the prayer times",
        parameters: z.object({
          today: z.string(),
          lattitude: z.number(),
          longitude: z.number(),
        }),
        execute: async () => {
          let prayerTimes = await fetch(
            `https://api.aladhan.com/v1/timings/${today}?latitude=${lattitude}&longitude=${longitude}&method=2&school=1&adjustment=1`
          );
          let prayerTimeData = await prayerTimes.json();
          return prayerTimeData;
        },
      }),
      commute: tool({
        description: "Get the walking commute details",
        parameters: z.object({
          origin: z.string(),
          destination: z.string(),
          departureTime: z.string(),
        }),
        execute: async () => {
          let route = await fetch(
            `https://router.hereapi.com/v8/routes?apiKey=ucVnb1EI1wQzXUo275MLTRI94ZHlhyRXj2qVhsSu2bk&origin=${
              lattitude + "," + longitude
            }&destination=${work}&transportMode=pedestrian&routingMode=fast&units=metric&departureTime=${today}`
          );
          let routeData = await route.json();
          return routeData;
        },
      }),
    },
  });

  console.log(result.text);

  return c.json({
    text: result.text,
  });
});

let port = 3000;
console.log(`Server is running on port ${port}`);

serve({
  fetch: app.fetch,
  port,
});
