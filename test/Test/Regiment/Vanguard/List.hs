{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# OPTIONS_GHC -fno-warn-missing-signatures #-}
module Test.Regiment.Vanguard.List where

import qualified Data.ByteString as BS
import qualified Data.List as DL

import           Disorder.Jack (Property, gamble)

import           P

import           Regiment.Data
import           Regiment.Vanguard.Base
import           Regiment.Vanguard.List

import           Test.Regiment.Arbitrary

import           Test.QuickCheck.Instances ()
import           Test.QuickCheck.Jack (Jack, forAllProperties, quickCheckWithResult, (===))
import           Test.QuickCheck.Jack (maxSuccess, stdArgs)

runVanguardOn :: Jack [[KeyedPayload]] -> Property
runVanguardOn g =
  gamble g $ \kps ->
    let
      expected = payload <$> (DL.sort $ concat kps)
      ps = runVanguardList (DL.sort <$> kps)
    in
      Right expected === (ps :: Either (RegimentMergeError ()) [BS.ByteString])

prop_runVanguard_unique_keys :: Property
prop_runVanguard_unique_keys =
  runVanguardOn genListKPsUniqueKeys

prop_runVanguard_possible_dupe_sortkeys :: Property
prop_runVanguard_possible_dupe_sortkeys =
  -- by artificially removing payloads we are able to avoid
  -- test that runVanguard is the same as DL.sort. Retaining
  -- payloads means that we have to accomodate differences in
  -- the ordering of payloads between runVanguard and DL.sort
  -- when sort keys are exactly the same.
  runVanguardOn genListKPsNoPayload

return []
tests =
  $forAllProperties $ quickCheckWithResult (stdArgs {maxSuccess = 100})
